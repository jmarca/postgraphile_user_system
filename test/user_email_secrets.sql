-- Test user_email_secrets
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_private,public;

SELECT has_table('user_email_secrets');
SELECT has_pk( 'user_email_secrets' );

  SELECT has_column(        'user_email_secrets', 'user_email_id' );
SELECT col_type_is(       'user_email_secrets', 'user_email_id', 'uuid' );
SELECT col_not_null(      'user_email_secrets', 'user_email_id' );
SELECT col_hasnt_default( 'user_email_secrets', 'user_email_id' );

  SELECT has_column(        'user_email_secrets', 'verification_token' );
SELECT col_type_is(       'user_email_secrets', 'verification_token', 'text' );
SELECT col_is_null(      'user_email_secrets', 'verification_token' );
SELECT col_hasnt_default( 'user_email_secrets', 'verification_token' );

  SELECT has_column(        'user_email_secrets', 'verification_email_sent_at' );
SELECT col_type_is(       'user_email_secrets', 'verification_email_sent_at', 'timestamp with time zone' );
SELECT col_is_null(      'user_email_secrets', 'verification_email_sent_at' );
SELECT col_hasnt_default( 'user_email_secrets', 'verification_email_sent_at' );

  SELECT has_column(        'user_email_secrets', 'password_reset_email_sent_at' );
SELECT col_type_is(       'user_email_secrets', 'password_reset_email_sent_at', 'timestamp with time zone' );
SELECT col_is_null(      'user_email_secrets', 'password_reset_email_sent_at' );
SELECT col_hasnt_default( 'user_email_secrets', 'password_reset_email_sent_at' );


-- set up some test data
INSERT INTO app_public.users (username,name) VALUES ('jmarca', 'James E. Marca');

with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email)
   select uid.id, 'james@activimeowtricks.com' from uid;

-- should have an email
SELECT results_eq(
    'SELECT email FROM app_public.user_emails order by email',
    $$VALUES ('james@activimeowtricks.com'::citext) $$,
    'user_emails should hold an email'
);

-- should have an email secret as well
SELECT isnt_empty(
    'SELECT * FROM app_private.user_email_secrets',
    'insert should trigger insert into secrets');
SELECT isnt_empty(
    'SELECT a.user_email_id,a.verification_token FROM app_private.user_email_secrets a join  app_public.user_emails b on (b.id=a.user_email_id) where b.email=' || quote_literal('james@activimeowtricks.com') ,
     'insert into user email should trigger insert into secrets'
 );

-- test if verified is true case, not generate token
with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email, is_verified)
   select uid.id, 'james@activimetrics.com', true from uid;

SELECT results_eq(
    'SELECT email FROM app_public.user_emails order by email',
    $$VALUES ('james@activimeowtricks.com'::citext), ('james@activimetrics.com'::citext) $$,
    'user_emails should hold two now'
);
-- but the second should not trigger the verification token
SELECT isnt_empty(
    'SELECT a.user_email_id,a.verification_token FROM app_private.user_email_secrets a join  app_public.user_emails b on (b.id=a.user_email_id) where b.email=' || quote_literal('james@activimetrics.com') ,
     'insert verified true into user email should trigger insert into secrets, but no token'
 );
SELECT is_empty(
    'SELECT a.user_email_id,a.verification_token FROM app_private.user_email_secrets a join  app_public.user_emails b on (b.id=a.user_email_id) where a.verification_token is not null and  b.email=' || quote_literal('james@activimetrics.com') ,
     'insert verified true into user email should not trigger insert into secrets'
 );


SELECT finish();
ROLLBACK;
