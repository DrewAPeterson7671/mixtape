# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 14, 2026) — Clear Filters Toolbar Button

Added a "Clear Filters" button to the Album, Track, and Artist grid toolbars. Clicking it clears all column filters, search text, and proxy params in one action, then reloads the full dataset.

### Frontend
- **AlbumGrid.js, TrackGrid.js, ArtistGrid.js:** Added `Clear Filters` button (`fa fa-eraser` icon) to toolbar after Delete button, before the `'->'` spacer
- **AlbumController.js, TrackController.js, ArtistController.js:** Added `onClearFiltersClick` handler — deletes `search` extra param, calls `store.clearFilter(true)` to suppress auto-load, clears search textfield with events suspended, then calls `store.load()` once
- Pattern mirrors the proven `clearGridFilters` helper from `e2e/filtering.spec.js`

## Recent Changes (Apr 14, 2026) — Epoch Grid Columns + Filter

Added Epoch column with list filter to both album and track grids, with full backend filter support and E2E test coverage. Also added `epoch_name` to backend `FILTER_CONFIG` for both albums and tracks controllers.

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 14:** Clear Filters toolbar button on all three grids (album, track, artist)
- **Apr 14:** Epoch grid columns + list filter (backend FILTER_CONFIG + frontend columns + E2E tests)
- **Apr 14:** Album Wikipedia/Notes form fields, Edition Manager dropdown fix, CreatableTag trigger fix
- **Apr 12:** Epoch lookup entity (full stack: backend model/controller/specs + frontend model/store/views/controllers + E2E tests)
- **Apr 12:** CreatableTagField inline entity creation + E2E tests
- **Apr 8:** Album title uniqueness validation per artist; restore missing UserAlbum/UserTrack join records
- **Apr 7:** Sequence and definition columns on all lookup entities (5 backend + 26 frontend files), `remoteSort: false` fix for Ext JS stores
- **Apr 6:** Simplified per-user lookup ownership (pure per-user model, no system records), no-var code style enforcement
- **Apr 5:** E2E test coverage expansion (~80 new tests), backend RSpec coverage gaps (420 tests passing), tracklist column visibility, show endpoint for full user track data
- **Apr 4:** `anyMatch: true` on all artist/track typeahead components (5 comboboxes)
- **Apr 1:** Safer E2E test cleanup strategy (user-scoped catalog record cleanup, orphan detection, transaction wrapping)
- **Mar 28-30:** Server-side grid filtering & search, Add Track UX, DurationField bug fix, E2E tests
- **Mar 24-27:** CRUD & non-CRUD E2E tests, collection-scoped endpoints, artist cascade delete
- **Mar 22:** Playwright E2E infrastructure, test sub-agents, test orchestrator commands
- **Mar 10-13:** Inline track creation, edition management, DurationField, `various_artists` boolean
- **Earlier:** Track data model refactor, Album/Artist CRUD frontend, star rating, Cognito auth, RSpec migration
