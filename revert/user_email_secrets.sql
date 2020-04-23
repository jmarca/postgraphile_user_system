-- Revert postgraphile_user_system:user_email_secrets from pg

BEGIN;

SET search_path TO app_private,public;
DROP TRIGGER _500_insert_secrets ON app_public.user_emails;
DROP function tg_user_email_secrets__insert_With_user_email();
DROP TABLE user_email_secrets;

COMMIT;
