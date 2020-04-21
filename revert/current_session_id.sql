-- Revert postgraphile_user_system:current_session_id from pg

BEGIN;

DROP function app_public.current_session_id();

COMMIT;
