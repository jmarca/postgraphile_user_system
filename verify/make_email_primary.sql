-- Verify postgraphile_user_system:make_email_primary on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('make_email_primary(uuid)','execute');

ROLLBACK;
