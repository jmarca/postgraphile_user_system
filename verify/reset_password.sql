-- Verify postgraphile_user_system:reset_password on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('reset_password(uuid,text,text)','execute');

ROLLBACK;
