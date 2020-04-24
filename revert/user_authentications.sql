-- Revert postgraphile_user_system:user_authentications from pg

BEGIN;

SET search_path TO app_public,public;
DROP TABLE user_authentications;

COMMIT;
