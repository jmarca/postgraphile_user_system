-- Verify postgraphile_user_system:current_user on pg

BEGIN;

SELECT has_function_privilege('app_public.current_user()', 'execute');

ROLLBACK;
