-- Revert postgraphile_user_system:current_user_id from pg

BEGIN;

DROP function app_public.current_user_id();

COMMIT;
