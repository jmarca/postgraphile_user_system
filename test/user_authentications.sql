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
SELECT col_hasnt_default( 'user_authentications', 'id' );

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
SELECT col_hasnt_default( 'user_authentications', 'details' );

  SELECT has_column(        'user_authentications', 'created_at' );
SELECT col_type_is(       'user_authentications', 'created_at', 'timestamp with time zone' );
SELECT col_not_null(      'user_authentications', 'created_at' );
SELECT col_hasnt_default( 'user_authentications', 'created_at' );

  SELECT has_column(        'user_authentications', 'updated_at' );
SELECT col_type_is(       'user_authentications', 'updated_at', 'timestamp with time zone' );
SELECT col_not_null(      'user_authentications', 'updated_at' );
SELECT col_hasnt_default( 'user_authentications', 'updated_at' );

  



SELECT finish();
ROLLBACK;
