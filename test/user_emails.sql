-- Test user_emails
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_public,public;

SELECT has_table('user_emails');
SELECT has_pk( 'user_emails' );

  SELECT has_column(        'user_emails', 'id' );
SELECT col_type_is(       'user_emails', 'id', 'uuid' );
SELECT col_not_null(      'user_emails', 'id' );
SELECT col_has_default( 'user_emails', 'id' );

  SELECT has_column(        'user_emails', 'user_id' );
SELECT col_type_is(       'user_emails', 'user_id', 'uuid' );
SELECT col_not_null(      'user_emails', 'user_id' );
SELECT col_has_default( 'user_emails', 'user_id' );

  SELECT has_column(        'user_emails', 'email' );
SELECT col_type_is(       'user_emails', 'email', 'citext' );
SELECT col_not_null(      'user_emails', 'email' );
SELECT col_hasnt_default( 'user_emails', 'email' );

  SELECT has_column(        'user_emails', 'is_verified' );
SELECT col_type_is(       'user_emails', 'is_verified', 'boolean' );
SELECT col_not_null(      'user_emails', 'is_verified' );
SELECT col_has_default( 'user_emails', 'is_verified' );

  SELECT has_column(        'user_emails', 'is_primary' );
SELECT col_type_is(       'user_emails', 'is_primary', 'boolean' );
SELECT col_not_null(      'user_emails', 'is_primary' );
SELECT col_has_default( 'user_emails', 'is_primary' );

  SELECT has_column(        'user_emails', 'created_at' );
SELECT col_type_is(       'user_emails', 'created_at', 'timestamp with time zone' );
SELECT col_not_null(      'user_emails', 'created_at' );
SELECT col_has_default( 'user_emails', 'created_at' );

  SELECT has_column(        'user_emails', 'updated_at' );
SELECT col_type_is(       'user_emails', 'updated_at', 'timestamp with time zone' );
SELECT col_not_null(      'user_emails', 'updated_at' );
SELECT col_has_default( 'user_emails', 'updated_at' );

-- check other things

-- test that last email isn't deleted

-- set up some test data
INSERT INTO app_public.users (username,name) VALUES ('jmarca', 'James E. Marca');

with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email)
   select uid.id, 'james@activimeowtricks.com' from uid;

with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_private.sessions (user_id)
   select uid.id  from uid;

-- fake current user checks

with
uid(id) as (select id from app_public.users where username='jmarca'),
sid(uuid) as (select uuid from app_private.sessions s join uid u on (u.id=s.user_id))
select set_config('jwt.claims.session_id', sid.uuid::text, true)
from sid;

SET ROLE :DATABASE_VISITOR;

SELECT results_eq(
    'SELECT email, is_verified FROM app_public.user_emails order by email',
    $$VALUES ('james@activimeowtricks.com'::citext, false)$$,
    'user_emails should hold meowtricks only, unverified'
);

DELETE FROM app_public.user_emails WHERE email='james@activimeowtricks.com';
-- nothing happened
SELECT results_eq(
    'SELECT email, is_verified FROM app_public.user_emails order by email',
    $$VALUES ('james@activimeowtricks.com'::citext, false)$$,
    'user_emails should still hold meowtricks version'
);


set role postgres;
with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email)
   select uid.id, 'james@activimetrics.com' from uid;

set role :DATABASE_VISITOR;

SELECT results_eq(
    'SELECT user_id, email, is_verified FROM app_public.user_emails order by email',
    $$VALUES (app_public.current_user_id(),'james@activimeowtricks.com'::citext, false),
             (app_public.current_user_id(),'james@activimetrics.com'::citext, false) $$,
    'user_emails should hold both emails now, both unverified'
);

DELETE FROM app_public.user_emails WHERE email='james@activimeowtricks.com';

SELECT results_eq(
    'SELECT email FROM app_public.user_emails order by email',
    $$VALUES ('james@activimetrics.com'::citext) $$,
    'user_emails should be back to one email'
);

DELETE FROM app_public.user_emails WHERE email='james@activimetrics.com';

SELECT results_eq(
    'SELECT email FROM app_public.user_emails order by email',
    $$VALUES ('james@activimetrics.com'::citext) $$,
    'user_emails should still have one email'
);


-- check case of verified emails.  should not be able to delete last
-- verified even if multiple unverified

set role postgres;

with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email, is_verified)
   select uid.id, 'james@activimeowtricks.com', true from uid;

set role :DATABASE_VISITOR;

-- now have one verified, one not verified.
-- should not be able to delete verified
-- should be able to delete unverified

SELECT results_eq(
    'SELECT email, is_verified FROM app_public.user_emails order by email',
    $$VALUES ('james@activimeowtricks.com'::citext,true),
             ('james@activimetrics.com'::citext, false) $$,
    'user_emails should hold both emails again, one verified'
);
-- should not succeed
DELETE FROM app_public.user_emails WHERE email='james@activimeowtricks.com';
SELECT results_eq(
    'SELECT email, is_verified FROM app_public.user_emails order by email',
    $$VALUES ('james@activimeowtricks.com'::citext,true),
             ('james@activimetrics.com'::citext, false) $$,
    'delete should fail, user_emails should still hold both emails, one verified'
);


-- should succeed
DELETE FROM app_public.user_emails WHERE email='james@activimetrics.com';
SELECT results_eq(
    'SELECT email, is_verified FROM app_public.user_emails order by email',
    $$VALUES ('james@activimeowtricks.com'::citext,true)$$,
    'delete of unverified should succeed, user_emails should hold one email, verified'
);

SELECT finish();
ROLLBACK;
