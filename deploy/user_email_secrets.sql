-- Deploy postgraphile_user_system:user_email_secrets to pg
-- requires: user_emails
-- requires: postgraphile_schemas:schemas
-- requires: postgraphile_extensions:uuid-ossp
-- requires: postgraphile_extensions:citext

BEGIN;

SET search_path TO app_private,public;

CREATE TABLE user_email_secrets (
      user_email_id uuid NOT NULL primary key references app_public.user_emails on delete cascade,
      verification_token text,
      verification_email_sent_at timestamp with time zone,
      password_reset_email_sent_at timestamp with time zone
);
alter table app_private.user_email_secrets enable row level security;
comment on table app_private.user_email_secrets is
  E'The contents of this table should never be visible to the user. Contains data mostly related to email verification and avoiding spamming users.';
comment on column app_private.user_email_secrets.password_reset_email_sent_at is
  E'We store the time the last password reset was sent to this email to prevent the email getting flooded.';
create function app_private.tg_user_email_secrets__insert_with_user_email() returns trigger as $$
declare
  v_verification_token text;
begin
  if NEW.is_verified is false then
    v_verification_token = encode(gen_random_bytes(7), 'hex');
  end if;
  insert into app_private.user_email_secrets(user_email_id, verification_token) values(NEW.id, v_verification_token);
  return NEW;
end;
$$ language plpgsql volatile security definer set search_path to pg_catalog, public, pg_temp;
create trigger _500_insert_secrets
  after insert on app_public.user_emails
  for each row
  execute procedure app_private.tg_user_email_secrets__insert_with_user_email();
comment on function app_private.tg_user_email_secrets__insert_with_user_email() is
  E'Ensures that every user_email record has an associated user_email_secret record.';


COMMIT;
