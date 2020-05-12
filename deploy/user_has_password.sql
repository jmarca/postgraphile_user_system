-- Deploy postgraphile_user_system:user_has_password to pg
-- requires: users
-- requires: user_secrets

BEGIN;

create or replace function app_public.users_has_password(u app_public.users) returns boolean as $$
  select (password_hash is not null) from app_private.user_secrets where user_secrets.user_id = u.id and u.id = app_public.current_user_id();
$$ language sql stable security definer set search_path to pg_catalog, public, pg_temp;


COMMIT;
