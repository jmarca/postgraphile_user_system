-- Revert postgraphile_user_system:resend_email_verification from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;


DROP FUNCTION resend_email_verification_code(uuid);

COMMIT;
