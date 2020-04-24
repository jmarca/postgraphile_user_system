-- Revert postgraphile_user_system:user_authentication_secrets from pg

BEGIN;

SET search_path TO app_private,public;
DROP TABLE user_authentication_secrets;

COMMIT;
