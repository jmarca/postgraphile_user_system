-- Test users
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_public,public;

SELECT has_table('users');
SELECT has_pk( 'users' );

  SELECT has_column(        'users', 'id' );
SELECT col_type_is(       'users', 'id', 'uuid' );
SELECT col_not_null(      'users', 'id' );
SELECT col_has_default( 'users', 'id' );

  SELECT has_column(        'users', 'is_admin' );
SELECT col_type_is(       'users', 'is_admin', 'boolean' );
SELECT col_not_null(      'users', 'is_admin' );
SELECT col_has_default( 'users', 'is_admin' );

  SELECT has_column(        'users', 'is_verified' );
SELECT col_type_is(       'users', 'is_verified', 'boolean' );
SELECT col_not_null(      'users', 'is_verified' );
SELECT col_has_default( 'users', 'is_verified' );

  SELECT has_column(        'users', 'created_at' );
SELECT col_type_is(       'users', 'created_at', 'timestamp with time zone' );
SELECT col_not_null(      'users', 'created_at' );
SELECT col_has_default( 'users', 'created_at' );

  SELECT has_column(        'users', 'updated_at' );
SELECT col_type_is(       'users', 'updated_at', 'timestamp with time zone' );
SELECT col_not_null(      'users', 'updated_at' );
SELECT col_has_default( 'users', 'updated_at' );

  SELECT has_column(        'users', 'username' );
SELECT col_type_is(       'users', 'username', 'citext' );
SELECT col_not_null(      'users', 'username' );
SELECT col_hasnt_default( 'users', 'username' );

  SELECT has_column(        'users', 'name' );
SELECT col_type_is(       'users', 'name', 'text' );
SELECT col_is_null(      'users', 'name' );
SELECT col_hasnt_default( 'users', 'name' );

  SELECT has_column(        'users', 'avatar_url' );
SELECT col_type_is(       'users', 'avatar_url', 'text' );
SELECT col_is_null(      'users', 'avatar_url' );
SELECT col_hasnt_default( 'users', 'avatar_url' );





SELECT finish();
ROLLBACK;
