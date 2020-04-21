-- Test user_secrets
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_private,public;

SELECT has_table('user_secrets');
SELECT has_pk( 'user_secrets' );

  SELECT has_column(        'user_secrets', 'user_id' );
SELECT col_type_is(       'user_secrets', 'user_id', 'uuid' );
SELECT col_not_null(      'user_secrets', 'user_id' );
SELECT col_hasnt_default( 'user_secrets', 'user_id' );

  SELECT has_column(        'user_secrets', 'password_hash' );
SELECT col_type_is(       'user_secrets', 'password_hash', 'text' );
SELECT col_is_null(      'user_secrets', 'password_hash' );
SELECT col_hasnt_default( 'user_secrets', 'password_hash' );

  SELECT has_column(        'user_secrets', 'last_login_at' );
SELECT col_type_is(       'user_secrets', 'last_login_at', 'timestamp with time zone' );
SELECT col_not_null(      'user_secrets', 'last_login_at' );
SELECT col_has_default( 'user_secrets', 'last_login_at' );

  SELECT has_column(        'user_secrets', 'failed_password_attempts' );
SELECT col_type_is(       'user_secrets', 'failed_password_attempts', 'integer' );
SELECT col_not_null(      'user_secrets', 'failed_password_attempts' );
SELECT col_has_default( 'user_secrets', 'failed_password_attempts' );

  SELECT has_column(        'user_secrets', 'first_failed_password_attempt' );
SELECT col_type_is(       'user_secrets', 'first_failed_password_attempt', 'timestamp with time zone' );
SELECT col_is_null(      'user_secrets', 'first_failed_password_attempt' );
SELECT col_hasnt_default( 'user_secrets', 'first_failed_password_attempt' );

  SELECT has_column(        'user_secrets', 'reset_password_token' );
SELECT col_type_is(       'user_secrets', 'reset_password_token', 'text' );
SELECT col_is_null(      'user_secrets', 'reset_password_token' );
SELECT col_hasnt_default( 'user_secrets', 'reset_password_token' );

  SELECT has_column(        'user_secrets', 'reset_password_token_generated' );
SELECT col_type_is(       'user_secrets', 'reset_password_token_generated', 'timestamp with time zone' );
SELECT col_is_null(      'user_secrets', 'reset_password_token_generated' );
SELECT col_hasnt_default( 'user_secrets', 'reset_password_token_generated' );

  SELECT has_column(        'user_secrets', 'failed_reset_password_attempts' );
SELECT col_type_is(       'user_secrets', 'failed_reset_password_attempts', 'integer' );
SELECT col_not_null(      'user_secrets', 'failed_reset_password_attempts' );
SELECT col_has_default( 'user_secrets', 'failed_reset_password_attempts' );

  SELECT has_column(        'user_secrets', 'first_failed_reset_password_attempt' );
SELECT col_type_is(       'user_secrets', 'first_failed_reset_password_attempt', 'timestamp with time zone' );
SELECT col_is_null(      'user_secrets', 'first_failed_reset_password_attempt' );
SELECT col_hasnt_default( 'user_secrets', 'first_failed_reset_password_attempt' );

  SELECT has_column(        'user_secrets', 'delete_account_token' );
SELECT col_type_is(       'user_secrets', 'delete_account_token', 'text' );
SELECT col_is_null(      'user_secrets', 'delete_account_token' );
SELECT col_hasnt_default( 'user_secrets', 'delete_account_token' );

  SELECT has_column(        'user_secrets', 'delete_account_token_generated' );
SELECT col_type_is(       'user_secrets', 'delete_account_token_generated', 'timestamp with time zone' );
SELECT col_is_null(      'user_secrets', 'delete_account_token_generated' );
SELECT col_hasnt_default( 'user_secrets', 'delete_account_token_generated' );





SELECT finish();
ROLLBACK;
