-- Verify postgraphile_user_system:confirm_account_deletion on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('confirm_account_deletion(text)','execute');

ROLLBACK;
