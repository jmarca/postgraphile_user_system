-- Test simple_sessions
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_private,public;

SELECT has_table('connect_pg_simple_sessions');
SELECT has_pk( 'connect_pg_simple_sessions' );

  SELECT has_column(        'connect_pg_simple_sessions', 'sid' );
SELECT col_type_is(       'connect_pg_simple_sessions', 'sid', 'character varying' );
SELECT col_not_null(      'connect_pg_simple_sessions', 'sid' );
SELECT col_hasnt_default( 'connect_pg_simple_sessions', 'sid' );

  SELECT has_column(        'connect_pg_simple_sessions', 'sess' );
SELECT col_type_is(       'connect_pg_simple_sessions', 'sess', 'json' );
SELECT col_not_null(      'connect_pg_simple_sessions', 'sess' );
SELECT col_hasnt_default( 'connect_pg_simple_sessions', 'sess' );

  SELECT has_column(        'connect_pg_simple_sessions', 'expire' );
SELECT col_type_is(       'connect_pg_simple_sessions', 'expire', 'timestamp without time zone' );
SELECT col_not_null(      'connect_pg_simple_sessions', 'expire' );
SELECT col_hasnt_default( 'connect_pg_simple_sessions', 'expire' );





SELECT finish();
ROLLBACK;
