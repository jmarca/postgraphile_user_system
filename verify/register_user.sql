-- Verify postgraphile_user_system:register_user on pg

BEGIN;

SET SEARCH_PATH TO app_private,public;
SELECT pg_catalog.has_function_privilege('register_user(character varying,character varying,json,json,boolean)','execute');

ROLLBACK;
