-- Deploy postgraphile_user_system:user_authentications to pg
-- requires: users
-- requires: postgraphile_schemas:schemas
-- requires: postgraphile_extensions:uuid-ossp

BEGIN;

SET search_path TO app_public,public;

CREATE TABLE user_authentications (
      id uuid primary key NOT NULL  DEFAULT gen_random_uuid(),
      user_id uuid NOT NULL references users on delete cascade,
      service text NOT NULL,
      identifier text NOT NULL,
      details jsonb NOT NULL  DEFAULT '{}'::jsonb,
      created_at timestamp with time zone NOT NULL  DEFAULT now(),
      updated_at timestamp with time zone NOT NULL  DEFAULT now(),
      CONSTRAINT uniq_user_authentications UNIQUE(service, identifier)
);
ALTER TABLE user_authentications ENABLE ROW LEVEL SECURITY;

create index on app_public.user_authentications(user_id);
create trigger _100_timestamps
  before insert or update on app_public.user_authentications
  for each row
  execute procedure app_private.tg__timestamps();

comment on table app_public.user_authentications is
  E'Contains information about the login providers this user has used, so that they may disconnect them should they wish.';
comment on column app_public.user_authentications.service is
  E'The login service used, e.g. `twitter` or `github`.';
comment on column app_public.user_authentications.identifier is
  E'A unique identifier for the user within the login service.';
comment on column app_public.user_authentications.details is
  E'Additional profile details extracted from this login method';

create policy select_own on app_public.user_authentications for select using (user_id = app_public.current_user_id());
create policy delete_own
on app_public.user_authentications
for delete
using (
    user_id = app_public.current_user_id()
    AND
    -- either verified email exists,
    -- OR id is not first and is not last regardless of is_verified state
    (
     EXISTS( select 1
        from app_public.user_emails
        where user_id=app_public.current_user_id()
        and is_verified
        limit 1 )
    OR
    (
      NOT
        (id IN (select id
                  from app_public.user_authentications
                  where user_id=app_public.current_user_id()
                  order by id limit 1)
         AND
         id IN (select id
                  from app_public.user_authentications
                  where user_id=app_public.current_user_id()
                  order by id desc limit 1)
       )
     ))
);

create trigger _500_audit_removed
  after delete on app_public.user_authentications
  for each row
  execute procedure app_private.tg__add_audit_job(
    'unlinked_account',
    'user_id',
    'service',
    'identifier'
  );


grant select on app_public.user_authentications to :DATABASE_VISITOR;
grant delete on app_public.user_authentications to :DATABASE_VISITOR;


COMMIT;
