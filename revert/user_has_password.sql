-- Revert postgraphile_user_system:user_has_password from pg

BEGIN;

DROP FUNCTION app_public.users_has_password(app_public.users);

COMMIT;
