-- Deploy postgraphile_user_system:users to pg
-- requires: sessions
-- requires: postgraphile_roles:anonymous_role
-- requires: postgraphile_schemas:schemas
-- requires: postgraphile_extensions:uuid-ossp
-- requires: postgraphile_extensions:citext

BEGIN;

SET search_path TO app_public,public;

CREATE TABLE users (
      id uuid primary key NOT NULL  DEFAULT gen_random_uuid(),
      username citext NOT NULL unique check(length(username) >= 2 and length(username) <= 24),
      name text,
      avatar_url text check(avatar_url ~ '^https?://[^/]+'),
      is_admin boolean NOT NULL  DEFAULT false,
      is_verified boolean NOT NULL  DEFAULT false,
      created_at timestamp with time zone NOT NULL  DEFAULT now(),
      updated_at timestamp with time zone NOT NULL  DEFAULT now()
);

alter table app_public.users enable row level security;

alter table app_private.sessions add constraint sessions_user_id_fkey foreign key ("user_id") references app_public.users on delete cascade;
create index on app_private.sessions (user_id);

create policy select_all on app_public.users for select using (true);
create policy update_self on app_public.users for update using (id = app_public.current_user_id());
grant select on app_public.users to :DATABASE_VISITOR;
-- NOTE: `insert` is not granted, because we'll handle that separately
grant update(username, name, avatar_url) on app_public.users to :DATABASE_VISITOR;
-- NOTE: `delete` is not granted, because we require confirmation via request_account_deletion/confirm_account_deletion

comment on table app_public.users is
  E'A user who can log in to the application.';

comment on column app_public.users.id is
  E'Unique identifier for the user.';
comment on column app_public.users.username is
  E'Public-facing username of the user.';
comment on column app_public.users.name is
  E'Public-facing name (or pseudonym) of the user.';
comment on column app_public.users.avatar_url is
  E'Optional avatar URL.';
comment on column app_public.users.is_admin is
  E'If true, the user has elevated privileges.';

create trigger _100_timestamps
  before insert or update on app_public.users
  for each row
  execute procedure app_private.tg__timestamps();

COMMIT;
