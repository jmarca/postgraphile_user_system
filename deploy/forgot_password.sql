-- Deploy postgraphile_user_system:forgot_password to pg
-- requires: users
-- requires: user_emails
-- requires: user_authentications
-- requires: user_secrets
-- requires: user_email_secrets
-- requires: user_authentication_secrets
-- requires: unregistered_email_resets

BEGIN;

SET SEARCH_PATH TO app_public,public;
create function app_public.forgot_password(email citext) returns void as $$
declare
  v_user_email app_public.user_emails;
  v_token text;
  v_token_min_duration_between_emails interval = interval '3 minutes';
  v_token_max_duration interval = interval '3 days';
  v_now timestamptz = clock_timestamp(); -- Function can be called multiple during transaction
  v_latest_attempt timestamptz;
begin
  -- Find the matching user_email:
  select user_emails.* into v_user_email
  from app_public.user_emails
  where user_emails.email = forgot_password.email
  order by is_verified desc, id desc;

  -- If there is no match:
  if v_user_email is null then
    -- This email doesn't exist in the system; trigger an email stating as much.

    -- We do not allow this email to be triggered more than once every 15
    -- minutes, so we need to track it:
    insert into app_private.unregistered_email_password_resets (email, latest_attempt)
      values (forgot_password.email, v_now)
      on conflict on constraint unregistered_email_pkey
      do update
        set latest_attempt = v_now, attempts = unregistered_email_password_resets.attempts + 1
        where unregistered_email_password_resets.latest_attempt < v_now - interval '15 minutes'
      returning latest_attempt into v_latest_attempt;

    if v_latest_attempt = v_now then
      perform graphile_worker.add_job(
        'user__forgot_password_unregistered_email',
        json_build_object('email', forgot_password.email::text)
      );
    end if;

    -- TODO: we should clear out the unregistered_email_password_resets table periodically.

    return;
  end if;

  -- There was a match.
  -- See if we've triggered a reset recently:
  if exists(
    select 1
    from app_private.user_email_secrets
    where user_email_id = v_user_email.id
    and password_reset_email_sent_at is not null
    and password_reset_email_sent_at > v_now - v_token_min_duration_between_emails
  ) then
    -- If so, take no action.
    return;
  end if;

  -- Fetch or generate reset token:
  update app_private.user_secrets
  set
    reset_password_token = (
      case
      when reset_password_token is null or reset_password_token_generated < v_now - v_token_max_duration
      then encode(gen_random_bytes(7), 'hex')
      else reset_password_token
      end
    ),
    reset_password_token_generated = (
      case
      when reset_password_token is null or reset_password_token_generated < v_now - v_token_max_duration
      then v_now
      else reset_password_token_generated
      end
    )
  where user_id = v_user_email.user_id
  returning reset_password_token into v_token;

  -- Don't allow spamming an email:
  update app_private.user_email_secrets
  set password_reset_email_sent_at = v_now
  where user_email_id = v_user_email.id;

  -- Trigger email send:
  perform graphile_worker.add_job(
    'user__forgot_password',
    json_build_object('id', v_user_email.user_id, 'email', v_user_email.email::text, 'token', v_token)
  );

end;
$$ language plpgsql strict security definer volatile set search_path to pg_catalog, public, pg_temp;

COMMENT ON FUNCTION forgot_password (citext) is
  E'If you''ve forgotten your password, give us one of your email addresses and we''ll send you a reset token. Note this only works if you have added an email address!';

COMMIT;
