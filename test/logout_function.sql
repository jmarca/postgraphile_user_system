SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SELECT pass('Test logout_function!');

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

prepare session_check as
    select s.uuid,s.user_id
    from app_public.users u
    join app_private.sessions s on (s.user_id=u.id)
    where u.username='jmarca';

-- verify that session is set
SELECT isnt_empty('session_check','should set a session with logged-in user');
select isnt_empty('select app_public.current_user_id()', 'have a current user id');

select lives_ok('select app_public.logout()', 'logout function does not crash');

select is_empty('session_check','should not be a session any more');
select results_eq('select app_public.current_user_id()',
                  $$VALUES ((null::uuid)) $$,
                  'no more current user id');


SELECT finish();
ROLLBACK;
