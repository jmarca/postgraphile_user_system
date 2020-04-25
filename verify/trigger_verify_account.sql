-- Verify postgraphile_user_system:trigger_verify_account on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('tg_user_emails__verify_account_on_verified()','execute');
-- verify trigger too
select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='user_emails' and t.tgname='_500_verify_account_on_verified';

ROLLBACK;
