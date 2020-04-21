-- Revert postgraphile_user_system:users from pg

BEGIN;

SET search_path TO app_public,public;
DROP TRIGGER _100_timestamps ON users;
ALTER TABLE app_private.sessions DROP CONSTRAINT sessions_user_id_fkey;
DROP TABLE users;

COMMIT;
