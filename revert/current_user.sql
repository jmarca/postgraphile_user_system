-- Revert postgraphile_user_system:current_user from pg

BEGIN;

drop function app_public.current_user();

COMMIT;
