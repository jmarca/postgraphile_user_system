-- Deploy postgraphile_user_system:users_graphql_subscription to pg
-- requires: postgraphile_utility_functions:trigger_graphql_subscription

BEGIN;


create trigger _500_gql_update
  after update on app_public.users
  for each row
  execute procedure app_public.tg__graphql_subscription(
    'userChanged', -- the "event" string, useful for the client to know what happened
    'graphql:user:$1', -- the "topic" the event will be published to, as a template
    'id' -- If specified, `$1` above will be replaced with NEW.id or OLD.id from the trigger.
  );


COMMIT;
