-- Verify postgraphile_user_system:user_authentication_secrets on pg

BEGIN;

SET search_path TO app_private,public;
SELECT user_authentication_id, details
FROM user_authentication_secrets
WHERE FALSE;

ROLLBACK;
