-- Revert postgraphile_user_system:link_or_register_user from pg

BEGIN;

SET SEARCH_PATH TO app_private,public;


DROP FUNCTION link_or_register_user(uuid,character varying,character varying,json,json);

COMMIT;
