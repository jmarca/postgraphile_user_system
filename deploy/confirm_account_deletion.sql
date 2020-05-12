-- Deploy postgraphile_user_system:confirm_account_deletion to pg
-- requires: users
-- requires: user_emails
-- requires: user_authentications
-- requires: user_secrets
-- requires: user_email_secrets
-- requires: user_authentication_secrets
-- requires: unregistered_email_resets

BEGIN;

SET SEARCH_PATH TO app_public,public;
CREATE OR REPLACE FUNCTION confirm_account_deletion (  token text) RETURNS boolean AS
$$
declare
  v_user_secret app_private.user_secrets;
  v_token_max_duration interval = interval '3 days';
begin
  if app_public.current_user_id() is null then
    raise exception 'You must log in to delete your account' using errcode = 'LOGIN';
  end if;

  select * into v_user_secret
    from app_private.user_secrets
    where user_secrets.user_id = app_public.current_user_id();

  if v_user_secret is null then
    -- Success: they're already deleted
    -- but wierd, because session should be invalid.  so fix that
    perform app_public.logout();
    return true;
  end if;

  -- Check the token
  if(
      -- token is still valid
      v_user_secret.delete_account_token_generated > now() - v_token_max_duration
    and
      -- token matches
      v_user_secret.delete_account_token = token
    ) then
    -- Token passes
    -- Delete their account :(
    delete from app_public.users where id = app_public.current_user_id();
    -- also invalidate session
    perform app_public.logout();
    return true;
  end if;

  raise exception 'The supplied token was incorrect - perhaps you''re logged in to the wrong account, or the token has expired?' using errcode = 'DNIED';
end;
$$ language plpgsql strict volatile security definer set search_path to pg_catalog, public, pg_temp;

comment on function app_public.confirm_account_deletion(token text) is
  E'If you''re certain you want to delete your account, use `requestAccountDeletion` to request an account deletion token, and then supply the token through this mutation to complete account deletion.';

COMMIT;
