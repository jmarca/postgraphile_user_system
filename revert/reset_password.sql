-- Revert postgraphile_user_system:reset_password from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;


DROP FUNCTION reset_password(uuid,text,text);

COMMIT;
