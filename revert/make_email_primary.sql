-- Revert postgraphile_user_system:make_email_primary from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;


DROP FUNCTION make_email_primary(uuid);

COMMIT;
