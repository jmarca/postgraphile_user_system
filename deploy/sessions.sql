-- Deploy postgraphile_user_system:sessions to pg
-- requires: postgraphile_schemas:schemas
-- requires: postgraphile_extensions:uuid-ossp

BEGIN;

SET search_path TO app_private,public;

CREATE TABLE sessions (
      uuid uuid NOT NULL  DEFAULT gen_random_uuid() primary key,
      user_id uuid NOT NULL,
      created_at timestamp with time zone NOT NULL  DEFAULT now(),
      last_active timestamp with time zone NOT NULL  DEFAULT now()
);
alter table app_private.sessions enable row level security;

COMMIT;
