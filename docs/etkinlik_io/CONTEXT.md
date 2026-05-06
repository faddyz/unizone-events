# Etkinlik.io Context

Unizone uses Etkinlik.io as an admin-only editorial candidate pool. API data never publishes itself. Scans are manual, batch-based, and safe for Render Free + Supabase Free.

Flow:

1. Etkinlik.io API returns approved, not-started events.
2. Admin scan creates or updates `ExternalEventCandidate` rows.
3. Admin reviews candidates.
4. Approval creates a public `Event` immediately.

Constraints:

- No scheduled automation in v1.
- No always-running workers.
- No server-side poster downloads or image processing for API posters.
- API token lives only in ENV or ignored local `api.env`.
- Imported HTML must be sanitized or converted to text.
