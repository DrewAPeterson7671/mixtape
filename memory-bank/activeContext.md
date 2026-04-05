# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 5, 2026) — Backend RSpec Coverage Gaps

- **New spec: TestAuthController** (6 tests) — User creation + session, JSON response shape, email reuse (find_or_create_by), default name fallback, cognito_sub assignment, production environment gating (404)
- **New spec: ApplicationController** (7 tests) — `require_login` (401 vs allowed), `current_user` (nil, valid, stale ID), `set_current_user` (Current.user populated mid-request)
- **Lookup model validations** — Added `validate_uniqueness_of(:name)` to Edition, Genre, Medium, Phase, Priority, ReleaseType specs (were factory-only)
- **Sorting verification** (4 tests) — Article-stripping sort for artists, multi-key sort for albums (artist+title, VA under "various artists"), three-key sort for tracks, alphabetical sort for genres
- **Error/edge case specs** (17 tests) — 404 (RecordNotFound) for show/update/destroy on artists, albums, tracks, genres; 422 for invalid album year, duplicate genre name, duplicate playlist name per user (scoped uniqueness)
- **ExtJsFilterable edge cases** (4 tests) — LIKE wildcard escaping (`%`, `_`) in search and column filters, unknown number operator fallthrough, empty list filter results
- **Branch:** `mixtape-develop-20260405_backend_spec_gaps`

## Recent Changes (Apr 5, 2026) — Tracklist Column Visibility & Track Data from Show Endpoint

- **Frontend: ISRC, Listened, Rating, Genres columns now visible by default** — Removed `hidden: true` from these four tracklist columns. Edition column set to `hidden: true` by default (still toggled by `consider_editions` via `updateEditionVisibility`).
- **Frontend: Tracklist fetches from show endpoint** — `onGridCellClick` now makes a `GET /albums/:id` request to populate the tracklist instead of using `record.get('album_tracks')` from the index response. The index passes `{}` for user track prefs, so listened/rating/genres were always blank. The show endpoint loads full `UserTrack` records with genres/tags. Fresh data is written back to the grid record for use by `onConsiderEditionsChange` and other handlers.
- **Backend: `album_json` includes genre/tag data per track** — Added `genre_ids`, `genre_name`, `tag_ids`, `tag_name` to the per-track hash and `.includes(:genres, :tags)` on user_tracks queries.
- **Branches:** Backend `mixtape-develop-20260405_track_genre_names`, Frontend `mixtape-dev-20260405_track_genre_names`

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 4:** `anyMatch: true` on all artist/track typeahead components (5 comboboxes)
- **Apr 1:** Safer E2E test cleanup strategy (user-scoped catalog record cleanup, orphan detection, transaction wrapping)
- **Mar 28-30:** Server-side grid filtering & search, Add Track UX, DurationField bug fix, E2E tests
- **Mar 24-27:** CRUD & non-CRUD E2E tests, collection-scoped endpoints, artist cascade delete
- **Mar 22:** Playwright E2E infrastructure, test sub-agents, test orchestrator commands
- **Mar 10-13:** Inline track creation, edition management, DurationField, `various_artists` boolean
- **Earlier:** Track data model refactor, Album/Artist CRUD frontend, star rating, Cognito auth, RSpec migration
