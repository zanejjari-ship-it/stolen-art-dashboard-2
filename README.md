# Stolen Artworks Intelligence Dashboard

This is the stable Netlify + Supabase version. It has no ETL token, no frontend secret token, and no Netlify serverless refresh function. The dashboard reads directly from Supabase using the public anon/publishable key and the **Refresh view** button simply reloads the current database view.

## What is included

- React + Vite dashboard
- Supabase PostgreSQL database schema
- SQL seed data with 31 stolen-artwork records
- KPI cards, charts, filters, source links, and case table
- Local fallback data so the app does not show a blank screen if Supabase is not configured yet
- One-page executive summary

## Supabase setup

1. Create a free Supabase project.
2. Open **SQL Editor**.
3. Run `database/schema.sql`.
4. Run `database/seed_data.sql`.
5. Go to **Project Settings -> API**.
6. Copy your Project URL and publishable/anon key.

## Netlify setup

Deploy this project from GitHub. Use:

```text
Build command: npm run build
Publish directory: dist
Base directory: leave empty
```

Add only these two environment variables in Netlify:

```text
VITE_SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

Do **not** add these variables:

```text
ETL_TOKEN
VITE_ETL_TOKEN
SUPABASE_SERVICE_ROLE_KEY
```

They are not used in this stable version.

## Testing

After deployment, open your Netlify URL and click **Refresh view**. The button should reload the database records without 401, 500, or 501 errors.

If the app shows "Using local fallback data," check that the two `VITE_` variables are saved correctly and redeploy the site.

## Notes

This is an educational/demo dataset compiled from public information about famous art-theft cases. It is not an official law-enforcement registry.
