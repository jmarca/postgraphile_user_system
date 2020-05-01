SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;

SELECT no_plan();
--SELECT plan(1);

SET search_path TO app_public,public;

SELECT pass('Test confirm_account_deletion!');


INSERT INTO app_public.users (username,name) VALUES ('jmarca', 'James E. Marca');
INSERT INTO app_public.users (username,name) VALUES ('farfalla', 'Kitty A. Katt');
INSERT INTO app_public.users (username,name) VALUES ('gd', 'Greece Doll');

-- email
WITH uid(id) as (select id from app_public.users where username='jmarca')
insert into app_public.user_emails (user_id, email, is_verified)
   select uid.id, 'james@activimeowtricks.com', true from uid;

WITH uid(id) as (select id from app_public.users where username='farfalla')
insert into app_public.user_emails (user_id, email, is_verified)
   select uid.id, 'farfalla@activimeowtricks.com', true from uid;
WITH uid(id) as (select id from app_public.users where username='gd')
insert into app_public.user_emails (user_id, email, is_verified)
   select uid.id, 'athena@activimeowtricks.com', true from uid;


-- utility to snag token
create function app_public.get_delete_token() returns text as $$
  select delete_account_token from app_private.user_secrets where user_id = app_public.current_user_id();
$$ language sql stable security definer set search_path to pg_catalog, public, pg_temp;


-- fake session
with uid(id) as (select id from app_public.users where username='gd')
insert into app_private.sessions (user_id)
   select uid.id  from uid;
-- fake jwt claims
with
uid(id) as (select id from app_public.users where username='gd'),
sid(uuid) as (select uuid from app_private.sessions s join uid u on (u.id=s.user_id))
select set_config('jwt.claims.session_id', sid.uuid::text, true)
from sid;


SET ROLE :DATABASE_VISITOR;


select results_eq('select username from app_public.users u  order by username',
        'VALUES (' || quote_literal('farfalla') ||'::citext), ('  || quote_literal('gd') ||'::citext), (' || quote_literal('jmarca') ||'::citext)',
        'Should be able to view the current users');

-- delete own account

select app_public.request_account_deletion();

-- -- get the token that was generated
-- select delete_account_token
-- from update app_private.user_secrets
-- where user_id = app_public.current_user_id()
-- into v_token;

-- call the confirm delete function with bad token
select throws_ok('select app_public.confirm_account_deletion('||quote_literal('bob guy')||')',
       'DNIED',
       'The supplied token was incorrect - perhaps you''re logged in to the wrong account, or the token has expired?',
       'should not be able to delete self with bad token');


-- call the confirm delete function with correct token
select results_eq('select app_public.confirm_account_deletion(app_public.get_delete_token())',
        $$VALUES(true) $$,
        'should be able to delete self if not an org owner');



select results_eq('select username from app_public.users u  order by username',
        'VALUES (' || quote_literal('farfalla') ||'::citext), (' || quote_literal('jmarca') ||'::citext)',
        'Should be able to view the current users after delete gd');


SET ROLE postgres;


with uid(id) as (select id from app_public.users where username='jmarca')
insert into app_private.sessions (user_id)
   select uid.id  from uid;
-- fake jwt claims
with
uid(id) as (select id from app_public.users where username='jmarca'),
sid(uuid) as (select uuid from app_private.sessions s join uid u on (u.id=s.user_id))
select set_config('jwt.claims.session_id', sid.uuid::text, true)
from sid;


SET ROLE :DATABASE_VISITOR;

-- baseline
select results_eq('select username from  app_public.users u order by username',
        'VALUES (' || quote_literal('farfalla') ||'::citext), (' || quote_literal('jmarca') ||'::citext)',
        'Should be able to view the current users');

-- delete own account

select app_public.request_account_deletion();

-- call the confirm delete function
select lives_ok('select app_public.confirm_account_deletion(app_public.get_delete_token())',
        'should be able to delete self ');

select results_eq('select username from  app_public.users u order by username',
        'VALUES (' || quote_literal('farfalla') ||'::citext)',
        'Should be able to view the last remaining user');


SELECT finish();
ROLLBACK;
