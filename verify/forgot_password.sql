-- Verify postgraphile_user_system:forgot_password on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('forgot_password(citext)','execute');

ROLLBACK;
