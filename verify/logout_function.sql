-- Verify postgraphile_user_system:logout_function on pg

BEGIN;

SELECT has_function_privilege('app_public.logout()', 'execute');

ROLLBACK;
