-- Verify postgraphile_user_system:trigger_user_secrets_insert on pg

BEGIN;

SELECT has_function_privilege('app_private.tg_user_secrets__insert_with_user()', 'execute');

select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='users' and t.tgname='_500_insert_secrets';


ROLLBACK;
