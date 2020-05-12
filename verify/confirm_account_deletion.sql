-- Verify postgraphile_user_system:confirm_account_deletion on pg

BEGIN;

SET SEARCH_PATH TO app_public,public;
SELECT pg_catalog.has_function_privilege('confirm_account_deletion(text)','execute');

-- check that the change is done
-- just testing that the phrase 'organization_memberships' is in the new function
-- SELECT 1/COUNT(*)
--   FROM pg_catalog.pg_proc
--  WHERE proname = 'confirm_account_deletion';
--    AND pg_get_functiondef(oid) LIKE $$%organization_memberships%$$;


ROLLBACK;
