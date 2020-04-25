-- Revert postgraphile_user_system:trigger_verify_account from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;


DROP TRIGGER _500_verify_account_on_verified ON user_emails;
DROP FUNCTION tg_user_emails__verify_account_on_verified();

COMMIT;
