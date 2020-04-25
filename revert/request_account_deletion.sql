-- Revert postgraphile_user_system:request_account_deletion from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;


DROP FUNCTION request_account_deletion();

COMMIT;
