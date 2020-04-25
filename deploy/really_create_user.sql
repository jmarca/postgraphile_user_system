-- Deploy postgraphile_user_system:really_create_user to pg
-- requires: users
-- requires: user_emails
-- requires: user_authentications
-- requires: user_secrets
-- requires: user_email_secrets
-- requires: user_authentication_secrets
-- requires: unregistered_email_resets

BEGIN;

SET SEARCH_PATH TO app_private,public;
CREATE OR REPLACE FUNCTION really_create_user (
  username citext,
  email text,
  email_is_verified bool,
  name text,
  avatar_url text,
  password text default null
) RETURNS app_public.users AS
$$
declare
  v_user app_public.users;
  v_username citext = username;
begin
  if password is not null then
    perform app_private.assert_valid_password(password);
  end if;
  if email is null then
    raise exception 'Email is required' using errcode = 'MODAT';
  end if;

  -- Insert the new user
  insert into app_public.users (username, name, avatar_url) values
    (v_username, name, avatar_url)
    returning * into v_user;

	-- Add the user's email
  insert into app_public.user_emails (user_id, email, is_verified, is_primary)
  values (v_user.id, email, email_is_verified, email_is_verified);

  -- Store the password
  if password is not null then
    update app_private.user_secrets
    set password_hash = crypt(password, gen_salt('bf'))
    where user_id = v_user.id;
  end if;

  -- Refresh the user
  select * into v_user from app_public.users where id = v_user.id;

  return v_user;
end;
$$ language plpgsql volatile set search_path to pg_catalog, public, pg_temp;

comment on function app_private.really_create_user(username citext, email text, email_is_verified bool, name text, avatar_url text, password text) is
  E'Creates a user account. All arguments are optional, it trusts the calling method to perform sanitisation.';


COMMIT;
