-- Revert postgraphile_user_system:users_graphql_subscription from pg

BEGIN;

SET SEARCH_PATH TO app_public,public;

DROP TRIGGER _500_gql_update ON users;

COMMIT;
