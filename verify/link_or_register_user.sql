-- Verify postgraphile_user_system:link_or_register_user on pg

BEGIN;

SET SEARCH_PATH TO app_private,public;
SELECT pg_catalog.has_function_privilege('link_or_register_user(uuid,character varying,character varying,json,json)','execute');

ROLLBACK;
