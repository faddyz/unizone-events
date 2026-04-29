# Unizone

Unizone is a Rails event discovery and management platform. Registered users can create events, submit them for review, RSVP to public listings, and manage the events they host without a separate organizer role.

## Product Scope

- Public event discovery with search, filters, category browsing, and FriendlyId URLs.
- User-created events with a status lifecycle: draft, submitted, published, rejected, cancelled.
- Review workflow for quality control before events appear publicly.
- RSVP states: going, interested, not going.
- User dashboard for plans and hosted events.
- Server-rendered Rails UI with Tailwind, Stimulus, Devise, Pundit, Kaminari, and FriendlyId.

## Local Setup

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

For Docker-based local development:

```bash
docker compose up --build
```

## Demo Accounts

After running `bin/rails db:seed`, use:

- Admin: `admin@example.com` / `password123`
- Sample user: `member@example.com` / `password123`
- Sample host: `mina@example.com` / `password123`

## Key Routes

- `/` landing page
- `/explore` event discovery
- `/dashboard` user dashboard
- `/organizer/events` hosted event management
- `/admin/events` review queue

## Quality Checks

Run the core verification suite before publishing changes:

```bash
bin/rails test
bin/rails db:seed
```

## Render + Supabase Notes

- Set `DATABASE_URL` to the Supabase PostgreSQL connection string.
- Set `RAILS_MASTER_KEY`, `SECRET_KEY_BASE`, and `APP_HOST` in Render.
- Run `bin/rails db:migrate` on deploy, then `bin/rails db:seed` only for demo/staging environments.
- Use `bin/rails admin:create` with `ADMIN_EMAIL` and `ADMIN_PASSWORD` to bootstrap an admin safely.
- Free-tier deployments should rely on generated placeholder event posters unless persistent Active Storage is configured.

## License

MIT
