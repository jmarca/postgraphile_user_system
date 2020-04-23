-- Verify postgraphile_user_system:verify_email on pg

BEGIN;

SELECT has_function_privilege('app_public.verify_email(uuid,text)', 'execute');

ROLLBACK;
