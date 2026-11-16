-- Production hardening: the Next.js server mediates every data operation using
-- the service-role key after validating the Supabase Auth session and app role.
-- Browser clients use the anon key only for Supabase Auth; they do not access
-- application tables directly through PostgREST.
--
-- Keep RLS enabled and force it on all tracker tables, remove the pilot-wide
-- access policies, and revoke table access from public client roles. The
-- service_role retains its grants and bypasses RLS for server-mediated queries.
DO $$
DECLARE
  table_name TEXT;
BEGIN
  FOREACH table_name IN ARRAY ARRAY[
    'app_config',
    'audit_log',
    'business_master',
    'category_master',
    'escalations',
    'followups',
    'hub_master',
    'issue_counter',
    'kam_feedback_justifications',
    'notifications',
    'pick_justifications',
    'sla_settings',
    'sync_log',
    'users_roles'
  ] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', table_name);
    EXECUTE format('ALTER TABLE public.%I FORCE ROW LEVEL SECURITY', table_name);
    EXECUTE format('DROP POLICY IF EXISTS pilot_all ON public.%I', table_name);
    EXECUTE format(
      'REVOKE ALL PRIVILEGES ON TABLE public.%I FROM PUBLIC, anon, authenticated',
      table_name
    );
  END LOOP;
END $$;

-- Prevent clients from calling the issue counter RPC directly. Trigger
-- functions are invoked by PostgreSQL, so touch_updated_at does not need a
-- client EXECUTE grant either.
REVOKE ALL PRIVILEGES ON FUNCTION public.next_issue_id() FROM PUBLIC, anon, authenticated;
REVOKE ALL PRIVILEGES ON FUNCTION public.touch_updated_at() FROM PUBLIC, anon, authenticated;

-- Future tables/sequences/functions created by the migration owner should not
-- automatically regain PostgREST access. Grant explicitly if a future feature
-- intentionally introduces a browser-facing data API.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE ALL ON SEQUENCES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
