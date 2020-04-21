-- Deploy postgraphile_user_system:simple_sessions to pg
-- requires: postgraphile_schemas:schemas

BEGIN;

SET search_path TO app_private,public;

CREATE TABLE connect_pg_simple_sessions (
      sid character varying NOT NULL,
      sess json NOT NULL,
      expire timestamp without time zone NOT NULL

);
alter table app_private.connect_pg_simple_sessions
  enable row level security;
alter table app_private.connect_pg_simple_sessions
  add constraint session_pkey primary key (sid) not deferrable initially immediate;

COMMIT;
