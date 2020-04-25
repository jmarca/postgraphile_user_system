-- Verify postgraphile_user_system:users_graphql_subscription on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='users' and t.tgname='_500_gql_update';


ROLLBACK;
