-- Verify postgraphile_user_system:user_has_password on pg

BEGIN;

SELECT has_function_privilege('app_public.users_has_password(app_public.users)', 'execute');

ROLLBACK;
