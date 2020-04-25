-- Verify postgraphile_user_system:resend_email_verification on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('resend_email_verification_code(uuid)','execute');

ROLLBACK;
