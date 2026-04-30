# Render + Supabase Free Demo Deploy

This project can run as a fully working Rails event platform on Render while using Supabase for persistent Postgres data. Demo records are manual and idempotent, so production behavior remains usable for real events later.

## Architecture

- Render Free Web Service runs Rails.
- Supabase Free Project stores PostgreSQL data.
- Demo seed data is refreshed manually with `bin/rails demo:refresh` or `bin/rails db:seed`.
- Event images should use Supabase Storage when persistence matters. Render's local filesystem is not durable on the free plan.

## Supabase Setup

1. Create a new Supabase project.
2. In **Project Settings > Database > Connection string**, copy the **Supavisor session mode** string.
   - Use session mode on port `5432` for Render unless you specifically need transaction mode.
   - If you use transaction mode on port `6543`, set `DATABASE_PREPARED_STATEMENTS=false`.
3. Put that connection string in Render as `DATABASE_URL`.
4. Keep the database small. The demo seed is tiny, but Supabase Free enters read-only mode after the free database quota is exceeded.

## Render Setup

In the Render Web Service:

- Runtime: Ruby
- Build Command: `./bin/render-build.sh`
- Start Command: `bundle exec puma -C config/puma.rb`

Environment variables:

```txt
RAILS_ENV=production
RAILS_MASTER_KEY=<config/master.key value>
SECRET_KEY_BASE=<rails secret output>
DATABASE_URL=<Supabase Supavisor session mode connection string>
APP_HOST=<your-render-domain-or-custom-domain>
ACTIVE_STORAGE_SERVICE=local
```

For Supabase transaction pooler only:

```txt
DATABASE_PREPARED_STATEMENTS=false
```

Do not add `db:seed` to the Render build command. Seeds are manual so deploys do not rewrite production data by accident.

## First Deploy

1. Set Render environment variables.
2. Deploy the service. The build script runs migrations.
3. Run the demo seed once from your local machine against Supabase:

```bash
DATABASE_URL="postgres://..." RAILS_ENV=production RAILS_MASTER_KEY="..." SECRET_KEY_BASE="..." bin/rails demo:refresh
```

You can also use `bin/rails db:seed`; `demo:refresh` is just a clearer alias.

Windows PowerShell helper:

```powershell
Copy-Item .env.production.local.example .env.production.local
# Fill .env.production.local with production DATABASE_URL, RAILS_MASTER_KEY, and SECRET_KEY_BASE.
.\script\refresh_demo_seed.ps1
```

## Refreshing Demo Dates

The seed uses relative dates. Re-run this whenever the public demo looks stale:

```bash
DATABASE_URL="postgres://..." RAILS_ENV=production RAILS_MASTER_KEY="..." SECRET_KEY_BASE="..." bin/rails demo:refresh
```

This does not drop the database. It updates the fictional demo users/events and reconciles demo RSVP records without duplicating them.

Recommended cadence for a portfolio demo: refresh monthly, or before sharing the site publicly.

## Event Images

Current seed data intentionally has no attached images. The UI renders category-based gradient placeholders.

For durable uploaded images on Render Free:

1. In Supabase, create a Storage bucket such as `event-posters`.
2. Enable S3 protocol access and create server-side S3 access keys.
3. Add these Render environment variables:

```txt
ACTIVE_STORAGE_SERVICE=supabase
SUPABASE_STORAGE_BUCKET=event-posters
SUPABASE_S3_ENDPOINT=https://<project-ref>.supabase.co/storage/v1/s3
SUPABASE_S3_REGION=<region from Supabase Storage S3 settings>
SUPABASE_S3_ACCESS_KEY_ID=<server-side S3 access key>
SUPABASE_S3_SECRET_ACCESS_KEY=<server-side S3 secret>
```

Keep S3 access keys only on the server. They should never be exposed in frontend JavaScript.

With this setup, uploaded event images are stored in Supabase Storage while Active Storage metadata stays in Supabase Postgres.
