-- Deploy postgraphile_user_system:logout_function to pg

BEGIN;

create or replace function app_public.logout() returns void as $$
begin
  -- Delete the session
  delete from app_private.sessions
  where uuid = app_public.current_session_id()
     OR user_id = app_public.current_user_id();
  -- Clear the identifier from the transaction
  perform set_config('jwt.claims.session_id', '', true);
end;
$$ language plpgsql security definer volatile set search_path to pg_catalog, public, pg_temp;

COMMIT;
