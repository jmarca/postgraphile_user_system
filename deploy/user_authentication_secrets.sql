-- Deploy postgraphile_user_system:user_authentication_secrets to pg
-- requires: user_authentications

BEGIN;

SET search_path TO app_private,public;

CREATE TABLE user_authentication_secrets (
      user_authentication_id uuid NOT NULL primary key references app_public.user_authentications on delete cascade,
      details jsonb NOT NULL DEFAULT '{}'::jsonb
);
ALTER TABLE user_authentication_secrets ENABLE ROW LEVEL SECURITY;

-- NOTE: user_authentication_secrets doesn't need an auto-inserter as we handle
-- that everywhere that can create a user_authentication row.
COMMIT;
