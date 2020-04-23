-- Revert postgraphile_user_system:verify_email from pg

BEGIN;

drop function app_public.verify_email(uuid,text);

COMMIT;
