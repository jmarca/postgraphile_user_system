-- Verify postgraphile_user_system:user_emails on pg

BEGIN;

SET search_path TO app_public,public;
SELECT id, user_id, email, is_verified, is_primary, created_at, updated_at
FROM user_emails
WHERE FALSE;

select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='user_emails' and t.tgname='_100_timestamps';

select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='user_emails' and t.tgname='_500_audit_added';

select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='user_emails' and t.tgname='_500_audit_removed';

SELECT has_function_privilege('app_public.tg_user_emails__forbid_if_verified()', 'execute');

select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='user_emails' and t.tgname='_200_forbid_existing_email';

select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='user_emails' and t.tgname='_900_send_verification_email';

-- check policies exist
select 1/count(*)
from pg_policy p
join pg_class c on (c.oid=p.polrelid)
where c.relname='user_emails' and p.polname='select_own';

select 1/count(*)
from pg_policy p
join pg_class c on (c.oid=p.polrelid)
where c.relname='user_emails' and p.polname='insert_own';

select 1/count(*)
from pg_policy p
join pg_class c on (c.oid=p.polrelid)
where c.relname='user_emails' and p.polname='delete_own';

-- select 1/count(*)
-- from pg_policy p
-- join pg_class c on (c.oid=p.polrelid)
-- where c.relname='user_emails' and p.polname='keep_one_email';

SELECT 1/count(*)
from (select has_table_privilege(:'DATABASE_VISITOR','app_public.user_emails', 'select') as usge) a where usge;

SELECT 1/count(*)
from (select has_column_privilege(:'DATABASE_VISITOR','app_public.user_emails', 'email', 'insert') as usge) a where usge;

SELECT 1/count(*)
from (select has_table_privilege(:'DATABASE_VISITOR','app_public.user_emails', 'delete') as usge) a where usge;

-- not update
SELECT 1/count(*)
from (select has_table_privilege(:'DATABASE_VISITOR','app_public.user_emails', 'update') as usge) a where not usge;



ROLLBACK;
