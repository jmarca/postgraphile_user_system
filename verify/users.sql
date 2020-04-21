-- Verify postgraphile_user_system:users on pg

BEGIN;

SET search_path TO app_public,public;
SELECT id, is_admin, is_verified, created_at, updated_at, username, name, avatar_url
FROM users
WHERE FALSE;

ROLLBACK;
