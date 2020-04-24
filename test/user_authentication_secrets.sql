-- Test user_authentication_secrets
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_private,public;

SELECT has_table('user_authentication_secrets');
SELECT has_pk( 'user_authentication_secrets' );

  SELECT has_column(        'user_authentication_secrets', 'user_authentication_id' );
SELECT col_type_is(       'user_authentication_secrets', 'user_authentication_id', 'uuid' );
SELECT col_not_null(      'user_authentication_secrets', 'user_authentication_id' );
SELECT col_hasnt_default( 'user_authentication_secrets', 'user_authentication_id' );

  SELECT has_column(        'user_authentication_secrets', 'details' );
SELECT col_type_is(       'user_authentication_secrets', 'details', 'jsonb' );
SELECT col_not_null(      'user_authentication_secrets', 'details' );
SELECT col_has_default( 'user_authentication_secrets', 'details' );





SELECT finish();
ROLLBACK;
