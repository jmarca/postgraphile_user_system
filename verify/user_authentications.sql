-- Verify postgraphile_user_system:user_authentications on pg

BEGIN;

SET search_path TO app_public,public;
SELECT id, user_id, service, identifier, details, created_at, updated_at
FROM user_authentications
WHERE FALSE;

select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='user_authentications' and t.tgname='_100_timestamps';

-- check policies exist
select 1/count(*)
from pg_policy p
join pg_class c on (c.oid=p.polrelid)
where c.relname='user_authentications' and p.polname='select_own';

select 1/count(*)
from pg_policy p
join pg_class c on (c.oid=p.polrelid)
where c.relname='user_authentications' and p.polname='delete_own';

ROLLBACK;
