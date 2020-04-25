-- Revert postgraphile_user_system:change_password from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;


DROP FUNCTION change_password(text,text);

COMMIT;
