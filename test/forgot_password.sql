SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO public;

SELECT pass('Test forgot_password!');

-- test your function --

SELECT finish();
ROLLBACK;
