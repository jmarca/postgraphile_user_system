-- Revert postgraphile_user_system:really_create_user from pg

BEGIN;

SET SEARCH_PATH TO app_private,public;


DROP FUNCTION really_create_user(citext,text,bool,text,text,text);

COMMIT;
