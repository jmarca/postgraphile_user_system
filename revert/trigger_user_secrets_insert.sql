-- Revert postgraphile_user_system:trigger_user_secrets_insert from pg

BEGIN;

DROP TRIGGER _500_insert_secrets ON app_public.users;
DROP FUNCTION app_private.tg_user_secrets__insert_with_user();


COMMIT;
