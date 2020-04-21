-- Deploy postgraphile_user_system:trigger_user_secrets_insert to pg
-- requires: users
-- requires: user_secrets

BEGIN;

create function app_private.tg_user_secrets__insert_with_user() returns trigger as $$
begin
  insert into app_private.user_secrets(user_id) values(NEW.id);
  return NEW;
end;
$$ language plpgsql volatile set search_path to pg_catalog, public, pg_temp;

create trigger _500_insert_secrets
  after insert on app_public.users
  for each row
  execute procedure app_private.tg_user_secrets__insert_with_user();
comment on function app_private.tg_user_secrets__insert_with_user() is
  E'Ensures that every user record has an associated user_secret record.';


COMMIT;
