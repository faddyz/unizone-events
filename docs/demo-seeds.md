# Demo Seeds

Unizone demo seeds create a fictional, Turkey-focused event dataset for local portfolio demos. The seed data is designed to populate the homepage, explore page, popular events, event details, organizer workbench, admin review queue, and user RSVP dashboard without relying on external APIs or remote images.

Run manually:

```bash
bin/rails db:seed
```

Equivalent explicit refresh command:

```bash
bin/rails demo:refresh
```

On Windows PowerShell, use the helper script:

```powershell
Copy-Item .env.production.local.example .env.production.local
# Fill .env.production.local with the Supabase DATABASE_URL and Rails keys.
.\script\refresh_demo_seed.ps1
```

To reset existing demo account passwords while refreshing:

```powershell
.\script\refresh_demo_seed.ps1 -ResetPasswords
```

The seed is idempotent. It looks up users by email, refreshes known demo events by owner and title, and only reconciles RSVP records created by demo users on seeded demo events. Non-demo user data is preserved.

## Demo Accounts

All demo accounts use `password123` when they are first created.

- Admin: `admin@example.com`
- Sample organizer: `mina@example.com`
- Sample member: `member@example.com`

Existing demo account passwords are not overwritten by default. To reset them intentionally:

```bash
DEMO_SEED_RESET_PASSWORDS=1 bin/rails db:seed
```

## Event Data

The event set is fictional and demo-friendly. It includes mostly upcoming published events, plus submitted, draft, rejected, and cancelled records for admin and organizer flows.

Dates are relative to the seed run date, so the public site stays useful after later refreshes. Prices use realistic TRY ranges and events use the app's existing category enum values.

For a long-running portfolio demo, re-run the seed monthly or before sharing the site. It refreshes dates and RSVP distribution without dropping the database.

## Posters

No image files are attached by this seed. The current UI already renders category-based gradient placeholders when an event has no Active Storage image.

Later, local poster files can be added to the project and attached from the seed without using remote URLs.
