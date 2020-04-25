-- Deploy postgraphile_user_system:trigger_verify_account to pg
-- requires: users
-- requires: user_emails
-- requires: user_authentications
-- requires: user_secrets
-- requires: user_email_secrets
-- requires: user_authentication_secrets
-- requires: unregistered_email_resets

BEGIN;

SET SEARCH_PATH TO app_public,public;
CREATE OR REPLACE FUNCTION tg_user_emails__verify_account_on_verified () RETURNS trigger AS
$$
begin
  update app_public.users set is_verified = true where id = new.user_id and is_verified is false;
  return new;
end;
$$ language plpgsql strict volatile security definer set search_path to pg_catalog, public, pg_temp;

create trigger _500_verify_account_on_verified
  after insert or update of is_verified
  on app_public.user_emails
  for each row
  when (new.is_verified is true)
  execute procedure app_public.tg_user_emails__verify_account_on_verified();


COMMIT;
