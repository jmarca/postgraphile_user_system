-- Test sessions
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_private,public;

SELECT has_table('sessions');
SELECT has_pk( 'sessions' );

  SELECT has_column(        'sessions', 'uuid' );
SELECT col_type_is(       'sessions', 'uuid', 'uuid' );
SELECT col_not_null(      'sessions', 'uuid' );
SELECT col_has_default( 'sessions', 'uuid' );

  SELECT has_column(        'sessions', 'created_at' );
SELECT col_type_is(       'sessions', 'created_at', 'timestamp with time zone' );
SELECT col_not_null(      'sessions', 'created_at' );
SELECT col_has_default( 'sessions', 'created_at' );

  SELECT has_column(        'sessions', 'last_active' );
SELECT col_type_is(       'sessions', 'last_active', 'timestamp with time zone' );
SELECT col_not_null(      'sessions', 'last_active' );
SELECT col_has_default( 'sessions', 'last_active' );

  SELECT has_column(        'sessions', 'user_id' );
SELECT col_type_is(       'sessions', 'user_id', 'json' );
SELECT col_not_null(      'sessions', 'user_id' );
SELECT col_hasnt_default( 'sessions', 'user_id' );





SELECT finish();
ROLLBACK;
