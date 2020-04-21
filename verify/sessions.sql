-- Verify postgraphile_user_system:sessions on pg

BEGIN;

SET search_path TO app_private,public;
SELECT uuid, created_at, last_active, user_id
FROM sessions
WHERE FALSE;

ROLLBACK;
