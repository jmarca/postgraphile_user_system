SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SELECT pass('Test verify_email!');

-- set up some test data
INSERT INTO app_public.users (username,name) VALUES ('jmarca', 'James E. Marca');

with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email)
   select uid.id, 'james@activimeowtricks.com' from uid;

-- should have an email
SELECT results_eq(
    'SELECT email, is_verified FROM app_public.user_emails where email=' || quote_literal('james@activimeowtricks.com'),
    $$VALUES ('james@activimeowtricks.com'::citext, false) $$,
    'user_emails should hold an email, is not verified'
);
-- and the triggered secret
SELECT isnt_empty(
    'SELECT a.user_email_id,a.verification_token FROM app_private.user_email_secrets a join  app_public.user_emails b on (b.id=a.user_email_id) where b.email=' || quote_literal('james@activimeowtricks.com') ,
     'insert into user email should trigger insert into secrets'
 );

-- calling function should set verified to true
with
uid(id) as (select id from app_public.users where username='jmarca'),
email(id) as (select a.id from app_public.user_emails a join uid b on (a.user_id=b.id)),
token(id, token) as (select b.id, a.verification_token as token from app_private.user_email_secrets a join email b on (b.id=a.user_email_id))
select app_public.verify_email(t.id,t.token) from token t;


-- and now, verified should be true
SELECT results_eq(
    'SELECT email, is_verified FROM app_public.user_emails where email=' || quote_literal('james@activimeowtricks.com'),
    $$VALUES ('james@activimeowtricks.com'::citext, true) $$,
    'user_emails should hold an email, is verified'
);


SELECT finish();
ROLLBACK;
