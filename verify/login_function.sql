-- Verify postgraphile_user_system:login_function on pg

BEGIN;

SELECT has_function_privilege('app_private.login(citext, text)', 'execute');

ROLLBACK;
