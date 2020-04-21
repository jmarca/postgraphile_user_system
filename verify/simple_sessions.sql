-- Verify postgraphile_user_system:simple_sessions on pg

BEGIN;

SET search_path TO app_private,public;
SELECT sid, sess, expire
FROM connect_pg_simple_sessions
WHERE FALSE;

ROLLBACK;
