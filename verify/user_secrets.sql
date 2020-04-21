-- Verify postgraphile_user_system:user_secrets on pg

BEGIN;

SET search_path TO app_private,public;
SELECT user_id, password_hash, last_login_at, failed_password_attempts, first_failed_password_attempt, reset_password_token, reset_password_token_generated, failed_reset_password_attempts, first_failed_reset_password_attempt, delete_account_token, delete_account_token_generated
FROM user_secrets
WHERE FALSE;

ROLLBACK;
