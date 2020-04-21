-- Deploy postgraphile_user_system:current_user_id to pg
-- requires: postgraphile_schemas:schemas
-- requires: sessions

BEGIN;

create function app_public.current_user_id() returns uuid as $$
  select user_id from app_private.sessions where uuid = app_public.current_session_id();
$$ language sql stable security definer set search_path to pg_catalog, public, pg_temp;
comment on function app_public.current_user_id() is
  E'Handy method to get the current user ID for use in RLS policies, etc; in GraphQL, use `currentUser{id}` instead.';

COMMIT;
