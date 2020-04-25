-- Verify postgraphile_user_system:request_account_deletion on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('request_account_deletion()','execute');

ROLLBACK;
