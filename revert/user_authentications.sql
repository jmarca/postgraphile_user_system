-- Revert postgraphile_user_system:user_authentications from pg

BEGIN;

SET search_path TO app_public,public;
DROP TRIGGER _100_timestamps ON user_authentications;
DROP TRIGGER _500_audit_removed ON user_authentications;
DROP TABLE user_authentications;

COMMIT;
