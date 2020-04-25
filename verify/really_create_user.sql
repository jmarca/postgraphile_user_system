-- Verify postgraphile_user_system:really_create_user on pg

BEGIN;

SET SEARCH_PATH TO app_private,public;
SELECT pg_catalog.has_function_privilege('really_create_user(citext,text,bool,text,text,text)','execute');

ROLLBACK;
