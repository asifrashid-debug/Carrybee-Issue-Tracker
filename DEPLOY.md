# Deployment gate

Do not deploy this branch to production as part of the build task. First review the local preview, then explicitly approve a Vercel preview deployment.

The existing Vercel project is already associated with `asifrashid-debug/carrybee-issue-escalation`, not this repository. Do not retarget it or create another Vercel project without approval.

Before a connected Vercel preview can read tracker data, establish an isolated preview-safe Supabase environment and credentials. The current project uses permissive pilot RLS policies, so do not make the production service-role key available to preview deployments. Keep the production Vercel configuration unchanged until the owner approves a deployment plan.

The application uses the environment names in `.env.example`. Supabase service credentials, Google OAuth credentials, spreadsheet IDs and the webhook secret are server-only; never commit them or expose them under a `NEXT_PUBLIC_` variable.
