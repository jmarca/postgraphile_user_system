-- Verify postgraphile_user_system:change_password on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('change_password(text,text)','execute');

ROLLBACK;
