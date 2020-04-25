-- Revert postgraphile_user_system:forgot_password from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;


DROP FUNCTION forgot_password(citext);

COMMIT;
