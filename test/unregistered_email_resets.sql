-- Test unregistered_email_resets
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_private,public;

SELECT has_table('unregistered_email_password_resets');
SELECT has_pk( 'unregistered_email_password_resets' );

  SELECT has_column(        'unregistered_email_password_resets', 'email' );
SELECT col_type_is(       'unregistered_email_password_resets', 'email', 'citext' );
SELECT col_not_null(      'unregistered_email_password_resets', 'email' );
SELECT col_hasnt_default( 'unregistered_email_password_resets', 'email' );

  SELECT has_column(        'unregistered_email_password_resets', 'attempts' );
SELECT col_type_is(       'unregistered_email_password_resets', 'attempts', 'integer' );
SELECT col_not_null(      'unregistered_email_password_resets', 'attempts' );
SELECT col_has_default( 'unregistered_email_password_resets', 'attempts' );

  SELECT has_column(        'unregistered_email_password_resets', 'latest_attempt' );
SELECT col_type_is(       'unregistered_email_password_resets', 'latest_attempt', 'timestamp with time zone' );
SELECT col_not_null(      'unregistered_email_password_resets', 'latest_attempt' );
SELECT col_hasnt_default( 'unregistered_email_password_resets', 'latest_attempt' );





SELECT finish();
ROLLBACK;
