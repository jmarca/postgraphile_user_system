-- Revert postgraphile_user_system:simple_sessions from pg

BEGIN;

SET search_path TO app_private,public;
DROP TABLE connect_pg_simple_sessions;

COMMIT;
