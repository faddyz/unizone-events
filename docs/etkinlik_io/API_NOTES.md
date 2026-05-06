# Etkinlik.io API Notes

Verified base URL: `https://etkinlik.io/api/v2`

Auth header: `X-Etkinlik-Token`

`/events` params in the spec:

- `format_ids`
- `category_ids`
- `venue_ids`
- `city_ids`
- `start_gte`
- `end_lte`
- `skip`
- `take`

Conflict:

- Shared `status_ids` parameter says approved is `1`.
- `/events` does not list `status_ids`.
- `/events` description says it returns only approved and not-started events.

Decision: do not send `status_ids=1` in v1.

Sampling notes:

- `/cities` returned 84 rows.
- Target city IDs: Ankara `7`, Antalya `8`, Balikesir `12`, Bursa `21`, Eskisehir `32`, Istanbul `40`, Izmir `41`.
- `/events?take=50` returned about 180 KB for 50 items.
- Average event payload was about 3.1 KB; max was about 8 KB.
- 50/50 sampled events had `poster_url`, `ticket_url`, `url`, and `content`.
- 50/50 sampled `ticket_url` values pointed to `etkinlik.io`, so they are source/detail links unless proven otherwise.
