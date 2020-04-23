-- Verify postgraphile_user_system:user_email_secrets on pg

BEGIN;

SET search_path TO app_private,public;
SELECT user_email_id, verification_token, verification_email_sent_at, password_reset_email_sent_at
FROM user_email_secrets
WHERE FALSE;

SELECT has_function_privilege('tg_user_email_secrets__insert_with_user_email()', 'execute');

select 1/count(*)
from pg_trigger t
join pg_class c on (c.oid=t.tgrelid)
where c.relname='user_emails' and t.tgname='_500_insert_secrets';

ROLLBACK;
