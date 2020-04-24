SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SELECT pass('Test login_function!');

-- set up some test data
-- user
INSERT INTO app_public.users (username,name) VALUES ('jmarca', 'James E. Marca');

-- email (not a verified email)
WITH uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email, is_verified)
   select uid.id, 'james@activimeowtricks.com', true from uid;

-- insert a password
WITH uid(id) as (select id from app_public.users where username='jmarca')
update app_private.user_secrets
set
   password_hash = crypt('grobblefruit', gen_salt('bf')),
   failed_password_attempts = 0,
   first_failed_password_attempt = null,
   reset_password_token = null,
   reset_password_token_generated = null,
   failed_reset_password_attempts = 0,
   first_failed_reset_password_attempt = null
from uid
where user_secrets.user_id = uid.id;

-- now test that login function works

PREPARE badlogintest AS SELECT app_private.login('jmarca'::citext,'robblefruit');
PREPARE logintest AS SELECT app_private.login('jmarca'::citext,'grobblefruit');
PREPARE loginemailtest AS SELECT app_private.login('james@activimeowtricks.com'::citext,'grobblefruit');

SELECT results_eq( 'badlogintest',
                  $$VALUES ((null)::app_private.sessions)$$, 'bad password should return nothing');
SELECT isnt_empty( 'logintest', 'login okay is not empty');
SELECT results_ne( 'logintest',
                  $$VALUES ((null)::app_private.sessions)$$, 'good password does not return null record');
SELECT isnt_empty( 'loginemailtest', 'user_athentications via email is okay');

-- multiple bad logins will throw

SELECT lives_ok( 'badlogintest', 'bad login attempt 1');
SELECT lives_ok( 'badlogintest', 'bad login attempt 2');
SELECT lives_ok( 'badlogintest', 'bad login attempt 3 will still not throw, which means original bad login attempt was reset by good login attempts');
SELECT throws_ok( 'badlogintest',
                  'LOCKD',
                  'User account locked - too many login attempts. Try again after 5 minutes.',
                  'bad login attempt 4 will finally throw');



SELECT finish();
ROLLBACK;
