# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 5, 2026) — Frontend E2E Test Coverage Expansion

Comprehensive E2E audit and test writing across three priority tiers (~80 new tests, bringing total from ~104 to ~180+):

### P0: Lookup Entity CRUD & Complex UI
- **5 lookup entity specs** (Genres, Media, Phases, Priorities, Release Types) — Each has 3 grid tests + 3 serial CRUD tests. Uses `navigateToSettingsView` helper (new) for Settings tree expansion.
- **Edition Manager Modal spec** (15 tests) — Most complex spec: edition selector, dual-grid track management, add/remove/reorder/save/dirty-checking/create/clear/copy-to, disc number validation. Custom modal helpers.
- **Editions settings CRUD** — Same lookup entity pattern for Editions view.
- **Playlists grid spec** — Grid columns + data display. Creates genre first (required `belongs_to :genre`).
- **Tags grid spec** — Grid columns + data display.

### P1: Form Behavior & Backend Gaps
- **Genre auto-populate spec** (4 tests) — Verifies `onArtistChange` copies artist genres to album/track genre tagfield on new records, does NOT fire on existing records.
- **Form validation spec** (3 tests) — Tests `formBind` Save button disabled/enabled state. Custom `setFieldAndValidate` helper forces `checkValidity()` to bypass ExtJS async monitor.
- **UserAlbum model spec** (backend, 9 new tests) — `default_edition` association, `genre_name` method, genre/tag HABTM associations.

### P2: Grid Sorting & Tagfield Interactions
- **Grid sorting spec** (8 tests) — Tests column header click toggling ASC/DESC across Artists (Name, string), Albums (Year, numeric), Tracks (Title, string). Verifies sort indicator via `store.getSorters()` and data order. Also tests switching sort column replaces active sort.
- **Tagfield interactions spec** (10 tests) — Add multiple genres/tags, verify persistence after reload, remove/add values, clear all, verify empty. Typeahead filtering via `doRawQuery()` + picker verification. Select from filtered pick list.

- **Branches:** Frontend `mixtape-dev-20260405_lookup_entity_e2e_specs`, Backend `mixtape-develop-20260405_backend_spec_gaps`

## Recent Changes (Apr 5, 2026) — Backend RSpec Coverage Gaps

- **New spec: TestAuthController** (6 tests), **ApplicationController** (7 tests), **lookup model validations** (uniqueness on all 6 lookup models), **sorting verification** (4 tests), **error/edge case specs** (17 tests), **ExtJsFilterable edge cases** (4 tests)
- **Branch:** `mixtape-develop-20260405_backend_spec_gaps`

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 5:** Tracklist column visibility (ISRC, Listened, Rating, Genres visible by default), tracklist fetches from show endpoint for full user track data, `album_json` includes genre/tag data per track
- **Apr 4:** `anyMatch: true` on all artist/track typeahead components (5 comboboxes)
- **Apr 1:** Safer E2E test cleanup strategy (user-scoped catalog record cleanup, orphan detection, transaction wrapping)
- **Mar 28-30:** Server-side grid filtering & search, Add Track UX, DurationField bug fix, E2E tests
- **Mar 24-27:** CRUD & non-CRUD E2E tests, collection-scoped endpoints, artist cascade delete
- **Mar 22:** Playwright E2E infrastructure, test sub-agents, test orchestrator commands
- **Mar 10-13:** Inline track creation, edition management, DurationField, `various_artists` boolean
- **Earlier:** Track data model refactor, Album/Artist CRUD frontend, star rating, Cognito auth, RSpec migration
