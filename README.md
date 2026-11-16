# CarryBee Escalation Tracker (web view)

Single-file static site: tracker, issue drawer, analytics, hub/team performance, KAM/MX forms, admin and sync health.
No build step. Everything lives in `index.html`.

## Repo layout

```
.
├── index.html     # the full UI (your provided file, unchanged)
├── vercel.json    # clean URLs + basic security headers
├── .gitignore
└── README.md
```

## Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit: CarryBee escalation tracker UI"
git branch -M main
git remote add origin https://github.com/<your-user>/carrybee-escalation-tracker.git
git push -u origin main
```

## Deploy on Vercel

1. vercel.com → Add New → Project → Import the GitHub repo.
2. Framework Preset: **Other**. Build command: *(empty)*. Output directory: *(empty / root)*.
3. Deploy. Every push to `main` redeploys automatically.

## Notes

- All numbers in this file are **sample data**. To show live data, replace the `D`, `QUEUE`, `HUBS`, `CMS`, `SYNC` constants with a fetch to your Google Sheet / API.
- Page routes are hash based (`#/tracker`, `#/dashboard`, ...), so no rewrites are needed.
- The "Demo view" role switcher at the top is for preview only. Remove the `.demo-bar` block before production.
