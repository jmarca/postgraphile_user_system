-- Verify postgraphile_user_system:unregistered_email_resets on pg

BEGIN;

SET search_path TO app_private,public;
SELECT email, attempts, latest_attempt
FROM unregistered_email_password_resets
WHERE FALSE;

ROLLBACK;
