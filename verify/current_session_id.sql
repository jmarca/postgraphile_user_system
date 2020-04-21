-- Verify postgraphile_user_system:current_session_id on pg

BEGIN;

SELECT has_function_privilege('app_public.current_session_id()', 'execute');

ROLLBACK;
