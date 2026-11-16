# CarryBee Issue Escalation Tracker

Next.js application for the CarryBee issue escalation workflow. The app uses Supabase Auth for sign-in, server-side Supabase access for live tracker data, and the existing Google Sheets sync endpoints for the ISD, OSD and CTG zone sheets.

## Stack

- Next.js 16 / React 19
- Supabase Auth + Postgres (`escalations`, masters, audit, feedback, follow-ups and sync tables)
- Google Sheets zone sync via the existing webhook and reconciliation APIs
- Vercel deployment configuration (`vercel.json`, Singapore region)

No demo records are loaded by the application. Dashboard values, tracker rows, and charts come from the authenticated API and live database. Empty/error states are used when data cannot be retrieved.

## Local setup

1. Install Node.js 20+.
2. Copy `.env.example` to `.env.local` and set the values from the approved Vercel/Supabase project configuration. Do not commit `.env.local` or place service credentials in `NEXT_PUBLIC_*` variables.
3. Install and run:

   ```sh
   npm ci
   npm run dev
   ```

4. Run checks:

   ```sh
   npm test
   npm run build
   ```

Required server-side configuration is documented in `.env.example`. The Supabase service-role key is server-only; it must not be exposed to browser code. Preview deployments should use a separate, appropriately permissioned database/key rather than the production service-role key.

## Data and access

- Supabase project reference: `kssypfibhlmoxucabhdu` (ap-southeast-1).
- The database schema and migrations are in `supabase/migrations/`.
- All protected pages and APIs require a Supabase Auth session and an active `users_roles` row. Role tabs, visibility rules, and server API checks are in `lib/access.js`, `lib/roles.js`, `lib/visibility.js`, and `middleware.js`.
- Hubs and categories are read from Supabase masters. Admin settings/users are returned only to the admin role.
- Sheets credentials and OAuth/webhook secrets are server-side only. The service account should be granted only the access needed for the zone spreadsheets.

## Preview and deployment

Preview and Production run on the Vercel project `carrybee-issue-tracker`, which is connected to this repository. The separate `carrybee-escalation-tracker` project belongs to `asifrashid-debug/carrybee-issue-escalation`; leave that linkage unchanged.

The database was hardened in migration `014_harden_public_api.sql`. Every public table has RLS enabled and forced, the pilot-wide `pilot_all` policies were dropped, and `anon` / `authenticated` no longer hold table grants. The service-role key stays server-only and is the only way the application reaches tracker tables. See `DEPLOY.md` for the environment variables and the deployment checklist.

## Apps Script webhook target

The Apps Script handler is in `apps-script/Code.gs`. It expects the configured webhook URL and shared secret; keep that secret in the Apps Script properties and the Vercel server environment only.

`WEBHOOK_URL` points at the Production deployment (`https://carrybee-issue-tracker.vercel.app/api/webhook/sheet`). After changing the URL or the secret, re-paste `Code.gs` in each zone sheet (ISD, OSD, CTG), set `WEBHOOK_SECRET` in Script properties to the same value as the Vercel variable, then run `checkSetup()` and `installEditTrigger()` again. The endpoint returns 401 for a wrong secret and 503 when no secret is configured, so a failed probe is visible in the Apps Script log.
