-- Revert postgraphile_user_system:register_user from pg

BEGIN;

SET SEARCH_PATH TO app_private,public;


DROP FUNCTION register_user(character varying,character varying,json,json,boolean);

COMMIT;
