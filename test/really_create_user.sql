SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO app_private,public;

SELECT pass('Test really_create_user!');

-- test your function --

SELECT finish();
ROLLBACK;
