-- Verify postgraphile_user_system:current_user_id on pg

BEGIN;

SELECT has_function_privilege('app_public.current_user_id()', 'execute');

ROLLBACK;
