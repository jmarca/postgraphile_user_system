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

-- select c.email, c.email != d.email
-- from
-- app_public.user_emails c
-- join
--  (select case when a.firstemail=b.lastemail then a.firstemail else '' end as email
--  from (( select aa.email as firstemail from app_public.user_emails aa order by aa.email limit 1)a
--  join ( select aaa.email as lastemail from app_public.user_emails aaa order by aaa.email desc limit 1)b  on (true) )
--  ) d on (true);


PREPARE expected_a AS select 'james@activimeowtricks.com'::citext;
PREPARE expected_b AS select 'james@activimetrics.com'::citext;

PREPARE get_the_email AS select email FROM app_public.user_emails WHERE email='james@activimeowtricks.com';
PREPARE get_an_email AS select email FROM app_public.user_emails limit 1;

SET ROLE :DATABASE_VISITOR;

SELECT results_eq( 'get_the_email', 'expected_a', 'should get the email' );
DELETE FROM app_public.user_emails WHERE email='james@activimeowtricks.com';
-- nothing happened
SELECT results_eq( 'get_the_email', 'expected_a', 'should get the email' );

set role postgres;
with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email)
   select uid.id, 'james@activimetrics.com' from uid;

set role :DATABASE_VISITOR;

SELECT results_eq(
    'SELECT email FROM app_public.user_emails order by email',
    $$VALUES ('james@activimeowtricks.com'::citext), ('james@activimetrics.com'::citext) $$,
    'user_emails should hold both emails now'
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
    'user_emails should be back to one email'
);

SELECT results_eq( 'get_an_email', 'expected_b', 'should get the activimetrics version of email' );

SELECT finish();
ROLLBACK;
