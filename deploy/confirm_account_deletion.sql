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
    return true;
  end if;

  -- Check the token
  if v_user_secret.delete_account_token = token then
    -- Token passes

    -- Check that they are not the owner of any organizations
    if exists(
      select 1
      from app_public.organization_memberships
      where user_id = app_public.current_user_id()
      and is_owner is true
    ) then
      raise exception 'You cannot delete your account until you are not the owner of any organizations.' using errcode = 'OWNER';
    end if;

    -- Reassign billing contact status back to the organization owner
    update app_public.organization_memberships
      set is_billing_contact = true
      where is_owner = true
      and organization_id in (
        select organization_id
        from app_public.organization_memberships my_memberships
        where my_memberships.user_id = app_public.current_user_id()
        and is_billing_contact is true
      );

    -- Delete their account :(
    delete from app_public.users where id = app_public.current_user_id();
    return true;
  end if;

  raise exception 'The supplied token was incorrect - perhaps you''re logged in to the wrong account, or the token has expired?' using errcode = 'DNIED';
end;
$$ language plpgsql strict volatile security definer set search_path to pg_catalog, public, pg_temp;

comment on function app_public.confirm_account_deletion(token text) is
  E'If you''re certain you want to delete your account, use `requestAccountDeletion` to request an account deletion token, and then supply the token through this mutation to complete account deletion.';

COMMIT;
