-- Test user_authentications
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_public,public;

SELECT has_table('user_authentications');
SELECT has_pk( 'user_authentications' );

  SELECT has_column(        'user_authentications', 'id' );
SELECT col_type_is(       'user_authentications', 'id', 'uuid' );
SELECT col_not_null(      'user_authentications', 'id' );
SELECT col_has_default( 'user_authentications', 'id' );

  SELECT has_column(        'user_authentications', 'user_id' );
SELECT col_type_is(       'user_authentications', 'user_id', 'uuid' );
SELECT col_not_null(      'user_authentications', 'user_id' );
SELECT col_hasnt_default( 'user_authentications', 'user_id' );

  SELECT has_column(        'user_authentications', 'service' );
SELECT col_type_is(       'user_authentications', 'service', 'text' );
SELECT col_not_null(      'user_authentications', 'service' );
SELECT col_hasnt_default( 'user_authentications', 'service' );

  SELECT has_column(        'user_authentications', 'identifier' );
SELECT col_type_is(       'user_authentications', 'identifier', 'text' );
SELECT col_not_null(      'user_authentications', 'identifier' );
SELECT col_hasnt_default( 'user_authentications', 'identifier' );

  SELECT has_column(        'user_authentications', 'details' );
SELECT col_type_is(       'user_authentications', 'details', 'jsonb' );
SELECT col_not_null(      'user_authentications', 'details' );
SELECT col_has_default( 'user_authentications', 'details' );

  SELECT has_column(        'user_authentications', 'created_at' );
SELECT col_type_is(       'user_authentications', 'created_at', 'timestamp with time zone' );
SELECT col_not_null(      'user_authentications', 'created_at' );
SELECT col_has_default( 'user_authentications', 'created_at' );

  SELECT has_column(        'user_authentications', 'updated_at' );
SELECT col_type_is(       'user_authentications', 'updated_at', 'timestamp with time zone' );
SELECT col_not_null(      'user_authentications', 'updated_at' );
SELECT col_has_default( 'user_authentications', 'updated_at' );

-- now test policies
-- set up some test data
-- user
INSERT INTO app_public.users (username,name) VALUES ('jmarca', 'James E. Marca');

-- email (not a verified email)
WITH uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email)
   select uid.id, 'james@activimeowtricks.com' from uid;

-- auth provider
WITH uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_authentications (user_id, service, identifier)
   select uid.id, 'https://cas.activimetrics.com', 'CAS' from uid;

-- fake session
with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_private.sessions (user_id)
   select uid.id  from uid;
-- fake jwt claims
with
uid(id) as (select id from app_public.users where username='jmarca'),
sid(uuid) as (select uuid from app_private.sessions s join uid u on (u.id=s.user_id))
select set_config('jwt.claims.session_id', sid.uuid::text, true)
from sid;

-- TODO test that timestamp trigger fires
-- will need to look up how to store current timestamp value, then change table, then compare


SET ROLE :DATABASE_VISITOR;

SELECT results_eq(
    'SELECT service, identifier FROM app_public.user_authentications where user_id = app_public.current_user_id() order by identifier',
    $$VALUES ('https://cas.activimetrics.com', 'CAS')$$,
    'user_athentications holds CAS service'
);


DELETE FROM app_public.user_authentications WHERE identifier='CAS';

-- nothing happened
SELECT results_eq(
    'SELECT service, identifier FROM app_public.user_authentications where user_id = app_public.current_user_id() order by identifier',
    $$VALUES ('https://cas.activimetrics.com', 'CAS')$$,
    'user_athentications still holds CAS service'
);

-- add another provider
SET ROLE postgres;

WITH uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_authentications (user_id, service, identifier)
   select uid.id, 'geocities', 'all your base' from uid;

SET ROLE :DATABASE_VISITOR;

SELECT results_eq(
    'SELECT service, identifier FROM app_public.user_authentications where user_id = app_public.current_user_id() order by identifier',
    $$VALUES ('https://cas.activimetrics.com', 'CAS'),
             ('geocities', 'all your base')$$,
    'user_athentications holds CAS and geocities services'
);


DELETE FROM app_public.user_authentications WHERE identifier='CAS';

-- CAS got deleted
SELECT results_eq(
    'SELECT service, identifier FROM app_public.user_authentications where user_id = app_public.current_user_id() order by identifier',
    $$VALUES ('geocities', 'all your base')$$,
    'user_athentications no longer holds CAS service'
);

DELETE FROM app_public.user_authentications WHERE identifier='all your base';
SELECT results_eq(
    'SELECT service, identifier FROM app_public.user_authentications where user_id = app_public.current_user_id() order by identifier',
    $$VALUES ('geocities', 'all your base')$$,
    'user_athentications still holds all your base service'
);

-- add verified email
set role postgres;

with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email, is_verified)
   select uid.id, 'james@activimetrics.com', true from uid;

set role :DATABASE_VISITOR;

DELETE FROM app_public.user_authentications WHERE identifier='all your base';
SELECT is_empty(
    'select * FROM app_public.user_authentications where user_id = app_public.current_user_id() order by identifier',
    'user_athentications is empty'
);


SELECT finish();
ROLLBACK;
