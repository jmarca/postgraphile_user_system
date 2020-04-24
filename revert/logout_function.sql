-- Revert postgraphile_user_system:logout_function from pg

BEGIN;

drop function app_public.logout();

COMMIT;
