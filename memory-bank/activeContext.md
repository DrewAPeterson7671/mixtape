# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 6, 2026) — No-Var Code Style Enforcement

Eliminated all `var` declarations across the entire frontend codebase (906 total across 48 files). All JavaScript now uses `const` (preferred) or `let`.

### App Source Files (19 files, commit `4f531d0`)
- **AlbumController.js** (972 lines, 104 vars) — Largest file. Fixed a hoisting bug where `isNew` was used before its declaration. Renamed inner `albumTracks` → `refreshedTracks` to eliminate variable shadowing. Block scoping allowed removing `defaultEditionCheckbox2` workaround.
- **EditionManagerController.js** (84 vars), **TrackController.js** (36 vars), **ArtistController.js** (30 vars) — Large controller files analyzed by planner agent for `let` identification.
- **6 lookup controllers** (Genre, Medium, ReleaseType, Edition, Phase, Priority) — 18 vars each, identical patterns.
- **9 small files** (Track.js, EditionManagerModal.js, AlbumGrid.js, ArtistGrid.js, StarRating.js, MainController.js, AlbumDetail.js, TrackGrid.js, DurationField.js) — Straightforward conversions.

### E2E Test Files (29 files, commit `0d67c8a`)
- 424 vars bulk-converted (422 to const, 2 to let for reassigned `colIndex` variables).
- Loop iterators in `for` loops use `let`.
- Full code review confirmed zero false-passing-test risks from the conversion.
- **225 E2E tests: 223 pass, 1 flaky** (cancel-button detail-collapse timing, pre-existing).

### Conversion Rules Applied
- `const` when never reassigned (array mutations and object property assignments are not reassignments)
- `let` when genuinely reassigned (`url`, `method`, `errors`, `genreIds`, loop counters, etc.)
- `me = this` pattern (common in ExtJS) → always `const`

**Branch:** Frontend `mixtape-dev-20260406_no_var_code_style`

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 5:** E2E test coverage expansion (~80 new tests), backend RSpec coverage gaps (420 tests passing), tracklist column visibility, show endpoint for full user track data
- **Apr 4:** `anyMatch: true` on all artist/track typeahead components (5 comboboxes)
- **Apr 1:** Safer E2E test cleanup strategy (user-scoped catalog record cleanup, orphan detection, transaction wrapping)
- **Mar 28-30:** Server-side grid filtering & search, Add Track UX, DurationField bug fix, E2E tests
- **Mar 24-27:** CRUD & non-CRUD E2E tests, collection-scoped endpoints, artist cascade delete
- **Mar 22:** Playwright E2E infrastructure, test sub-agents, test orchestrator commands
- **Mar 10-13:** Inline track creation, edition management, DurationField, `various_artists` boolean
- **Earlier:** Track data model refactor, Album/Artist CRUD frontend, star rating, Cognito auth, RSpec migration
