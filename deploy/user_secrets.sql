-- Deploy postgraphile_user_system:user_secrets to pg
-- requires: users
-- requires: postgraphile_schemas:schemas
-- requires: postgraphile_extensions:uuid-ossp

BEGIN;

SET search_path TO app_private,public;

CREATE TABLE user_secrets (
      user_id uuid NOT NULL primary key references app_public.users on delete cascade,
      password_hash text,
      last_login_at timestamp with time zone NOT NULL  DEFAULT now(),
      failed_password_attempts integer NOT NULL DEFAULT 0,
      first_failed_password_attempt timestamp with time zone,
      reset_password_token text,
      reset_password_token_generated timestamp with time zone,
      failed_reset_password_attempts integer NOT NULL DEFAULT 0,
      first_failed_reset_password_attempt timestamp with time zone,
      delete_account_token text,
      delete_account_token_generated timestamp with time zone
);

alter table app_private.user_secrets enable row level security;
comment on table app_private.user_secrets is
  E'The contents of this table should never be visible to the user. Contains data mostly related to authentication.';

COMMIT;
