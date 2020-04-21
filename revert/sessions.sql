-- Revert postgraphile_user_system:sessions from pg

BEGIN;

SET search_path TO app_private,public;
DROP TABLE sessions;

COMMIT;
