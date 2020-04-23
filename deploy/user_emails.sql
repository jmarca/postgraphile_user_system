-- Deploy postgraphile_user_system:user_emails to pg
-- requires: users
-- requires: postgraphile_schemas:schemas
-- requires: postgraphile_extensions:uuid-ossp
-- requires: postgraphile_extensions:citext

BEGIN;

SET search_path TO app_public,public;

CREATE TABLE user_emails (
      id uuid primary key NOT NULL  DEFAULT gen_random_uuid(),
      user_id uuid NOT NULL  DEFAULT app_public.current_user_id() references app_public.users on delete cascade,
      email citext NOT NULL check (email ~ '[^@]+@[^@]+\.[^@]+'),
      is_verified boolean NOT NULL  DEFAULT false,
      is_primary boolean NOT NULL  DEFAULT false,
      created_at timestamp with time zone NOT NULL  DEFAULT now(),
      updated_at timestamp with time zone NOT NULL  DEFAULT now(),
      constraint user_emails_user_id_email_key unique(user_id, email),
      constraint user_emails_must_be_verified_to_be_primary check(is_primary is false or is_verified is true)
);
alter table app_public.user_emails enable row level security;

-- Once an email is verified, it may only be used by one user
create unique index uniq_user_emails_verified_email on app_public.user_emails(email) where (is_verified is true);

-- Only one primary email per user
create unique index uniq_user_emails_primary_email on app_public.user_emails (user_id) where (is_primary is true);

-- index for primary email
create index idx_user_emails_primary on app_public.user_emails (is_primary, user_id);

create trigger _100_timestamps
  before insert or update on app_public.user_emails
  for each row
  execute procedure app_private.tg__timestamps();
create trigger _500_audit_added
  after insert on app_public.user_emails
  for each row
  execute procedure app_private.tg__add_audit_job(
    'added_email',
    'user_id',
    'id',
    'email'
  );
create trigger _500_audit_removed
  after delete on app_public.user_emails
  for each row
  execute procedure app_private.tg__add_audit_job(
    'removed_email',
    'user_id',
    'id',
    'email'
  );

create function app_public.tg_user_emails__forbid_if_verified() returns trigger as $$
begin
  if exists(select 1 from app_public.user_emails where email = NEW.email and is_verified is true) then
    raise exception 'An account using that email address has already been created.' using errcode='EMTKN';
  end if;
  return NEW;
end;
$$ language plpgsql volatile security definer set search_path to pg_catalog, public, pg_temp;
create trigger _200_forbid_existing_email before insert on app_public.user_emails for each row execute procedure app_public.tg_user_emails__forbid_if_verified();

create trigger _900_send_verification_email
  after insert on app_public.user_emails
  for each row
  when (NEW.is_verified is false)
  execute procedure app_private.tg__add_job('user_emails__send_verification');

comment on table app_public.user_emails is
  E'Information about a user''s email address.';
comment on column app_public.user_emails.email is
  E'The users email address, in `a@b.c` format.';
comment on column app_public.user_emails.is_verified is
  E'True if the user has is_verified their email address (by clicking the link in the email we sent them, or logging in with a social login provider), false otherwise.';

-- policies
create policy select_own on app_public.user_emails for select using (user_id = app_public.current_user_id());
create policy insert_own on app_public.user_emails for insert with check (user_id = app_public.current_user_id());
-- No update
create policy delete_own
on app_public.user_emails
for delete
using (
    user_id = app_public.current_user_id()
    and
    email != (SELECT case when a.firstemail = b.lastemail then firstemail else '' end
               FROM (select email as firstemail from app_public.user_emails order by email limit 1 ) a
               join (select email as lastemail from app_public.user_emails order by email desc limit 1 ) b on (true)
               )
    );

-- create policy keep_one_email
-- on app_public.user_emails
-- for delete
-- using (
--      email != (SELECT case when a.firstemail = b.lastemail then firstemail else '' end
--                FROM (select email as firstemail from app_public.user_emails order by email limit 1 ) a
--                join (select email as lastemail from app_public.user_emails order by email desc limit 1 ) b on (true)
--                )
--     );

grant select on app_public.user_emails to :DATABASE_VISITOR;
grant insert (email) on app_public.user_emails to :DATABASE_VISITOR;
-- No update
grant delete on app_public.user_emails to :DATABASE_VISITOR;


COMMIT;
