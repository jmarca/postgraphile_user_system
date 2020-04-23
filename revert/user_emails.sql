-- Revert postgraphile_user_system:user_emails from pg

BEGIN;

SET search_path TO app_public,public;


DROP TABLE user_emails;
DROP FUNCTION app_public.tg_user_emails__forbid_if_verified();


COMMIT;
