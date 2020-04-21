-- Verify postgraphile_user_system:users on pg

BEGIN;

SET search_path TO app_public,public;
SELECT id, is_admin, is_verified, created_at, updated_at, username, name, avatar_url
FROM users
WHERE FALSE;

-- verify trigger too
select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='users' and t.tgname='_100_timestamps';

ROLLBACK;
