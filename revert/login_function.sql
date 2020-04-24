-- Revert postgraphile_user_system:login_function from pg

BEGIN;

drop function app_private.login(username citext, password text);

COMMIT;
