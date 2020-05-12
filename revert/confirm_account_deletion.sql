-- Revert postgraphile_user_system:confirm_account_deletion from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;


DROP FUNCTION confirm_account_deletion(text);

COMMIT;
