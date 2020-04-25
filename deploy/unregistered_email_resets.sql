-- Deploy postgraphile_user_system:unregistered_email_resets to pg
-- requires: users
-- requires: user_emails
-- requires: user_authentications
-- requires: user_secrets
-- requires: user_email_secrets
-- requires: user_authentication_secrets

BEGIN;

SET search_path TO app_private,public;

CREATE TABLE unregistered_email_password_resets (
      email citext NOT NULL constraint unregistered_email_pkey primary key,
      attempts integer NOT NULL  DEFAULT 1,
      latest_attempt timestamp with time zone NOT NULL
);
ALTER TABLE unregistered_email_password_resets ENABLE ROW LEVEL SECURITY;
comment on table app_private.unregistered_email_password_resets is
  E'If someone tries to recover the password for an email that is not registered in our system, this table enables us to rate-limit outgoing emails to avoid spamming.';
comment on column app_private.unregistered_email_password_resets.attempts is
  E'We store the number of attempts to help us detect accounts being attacked.';
comment on column app_private.unregistered_email_password_resets.latest_attempt is
  E'We store the time the last password reset was sent to this email to prevent the email getting flooded.';

COMMIT;
