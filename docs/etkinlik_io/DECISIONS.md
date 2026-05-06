# Etkinlik.io Decisions

- Do not pass `status_ids=1` to `/events`; the endpoint spec itself says list results are already approved and not started, while `status_ids` is not listed on `/events`.
- Use `venue_type` and `venue_data`; keep deprecated `venue` only inside `raw_data`.
- Treat `ticket_url` pointing to `etkinlik.io` as a source/detail fallback, not a real ticket link.
- Add `Online` as a valid event city so ONLINE candidates can publish without being forced into a physical city.
- Store remote posters as strings and render them directly in the browser.
- Candidate priority is an editorial sorting aid only, not popularity.
- `rejected` candidates never return to pending automatically; `skipped` is recoverable; `hidden` means outside current policy.
