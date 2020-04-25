-- Revert postgraphile_user_system:unregistered_email_resets from pg

BEGIN;

SET search_path TO app_private,public;
DROP TABLE unregistered_email_password_resets;

COMMIT;
