# Deployment notes

## Current state

- Vercel project: `carrybee-issue-tracker` (`prj_JfvNd7d0cAeHekGfhLlUnWSzoLwa`), connected to `asifrashid-debug/Carrybee-Issue-Tracker`.
- Supabase project: `kssypfibhlmoxucabhdu` (ap-southeast-1).
- The database was hardened by migration `harden_public_api` (`supabase/migrations/014_harden_public_api.sql`): RLS is enabled and forced on every public table, the pilot-wide `pilot_all` policies are gone, and `anon` / `authenticated` have no table grants. Browser clients use the anon key for Supabase Auth only.
- The existing Vercel project `carrybee-escalation-tracker` belongs to a different repository. Leave it unchanged.

## Environment variables (Production)

Public (safe to expose, used by Supabase Auth in the browser):

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

Server-only, never prefixed with `NEXT_PUBLIC_`:

- `SUPABASE_SERVICE_ROLE_KEY` — server data access; bypasses RLS after the app validates session and role.
- `WEBHOOK_SECRET` — shared secret for the Apps Script sheet webhook. The route fails closed (503) when this is unset.
- `SHEET_ISD`, `SHEET_OSD`, `SHEET_CTG` — zone spreadsheet IDs.
- `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_REFRESH_TOKEN` — sheet push/reconcile. Without these, writes still land in the database and the queue entry is recorded as `failed` in `sync_log`.

## Access model

1. Supabase Auth signs the user in (cookie session).
2. `middleware.js` maps the signed-in email to an active `users_roles` row and enforces tab access.
3. Route handlers re-check the session, then read and write through the server-side service-role client and apply `lib/roles.js` / `lib/visibility.js` scoping.

Because direct client table access is revoked, a leaked anon key alone cannot read or modify tracker data.

## Deployment checklist

1. Confirm the Production environment variables above are present.
2. Deploy to Production and open the project domain.
3. Set the Supabase Auth site URL and redirect allow-list to the project domain (already set to `https://carrybee-issue-tracker.vercel.app`).
4. Confirm Vercel Deployment Protection is off for Production, otherwise users hit a Vercel login wall instead of the tracker.
5. Verify sign-in, `/api/me`, the tracker list, and a sheet edit round-trip.

## Open follow-ups

- **Rotate the Supabase legacy `anon` and `service_role` JWTs.** They were displayed during setup, so treat them as exposed. Rotate the JWT secret in the Supabase dashboard, then update `NEXT_PUBLIC_SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` in Vercel Production and redeploy. The newer `sb_publishable_*` / `sb_secret_*` keys are the preferred replacement; Supabase masks their values after creation, so copy the new secret key at creation time.
- **Add `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_REFRESH_TOKEN`** to Vercel Production. Until then, tracker writes succeed but the sheet push is queued as `failed` in `sync_log` and `/sync` shows the backlog.
- **Re-install the Apps Script trigger in all three zone sheets** with `WEBHOOK_SECRET` set in Script properties. The apps script now posts to `https://carrybee-issue-tracker.vercel.app/api/webhook/sheet`.

## Preview environments

Preview has only `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`. Server routes there have no service-role key and no way to reach tracker tables (client roles lost their grants), so preview builds render but data calls fail. Add a server key to Preview only if a preview against live data is genuinely needed.
