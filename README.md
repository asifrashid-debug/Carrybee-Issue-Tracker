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

The local preview should be reviewed before creating or promoting a Vercel deployment. This repository branch is not the Git source currently attached to the existing Vercel project; that project is connected to `asifrashid-debug/carrybee-issue-escalation`. Do not change that linkage or deploy to production as part of local preview work.

The existing Supabase database currently has permissive pilot RLS policies. The server application enforces session and role checks, but direct database access is not least-privilege. Do not broaden preview credentials or use the production service-role key in a preview deployment until the owner approves a preview-safe database and RLS plan.

## Google Sheets webhook

The Apps Script handler is in `apps-script/Code.gs`. It expects the configured webhook URL and shared secret; keep that secret in the Apps Script properties and the Vercel server environment only.
