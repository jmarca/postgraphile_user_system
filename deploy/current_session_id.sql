-- Deploy postgraphile_user_system:current_session_id to pg
-- requires: postgraphile_schemas:schemas
-- requires: sessions

BEGIN;

create function app_public.current_session_id() returns uuid as $$
  select nullif(pg_catalog.current_setting('jwt.claims.session_id', true), '')::uuid;
$$ language sql stable;
comment on function app_public.current_session_id() is
  E'Handy method to get the current session ID.';


COMMIT;
