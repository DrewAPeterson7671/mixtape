# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 14, 2026) — Epoch Grid Columns + Filter

Added Epoch column with list filter to both album and track grids, with full backend filter support and E2E test coverage.

### Backend
- **AlbumsController:** Added `epoch_name` to `FILTER_CONFIG` as `:list` filter on `user_albums.epoch_id`
- **TracksController:** Added `epoch_name` to `FILTER_CONFIG` as `:list` filter on `user_tracks.epoch_id`
- **Filter specs:** Added `epoch_name` list filter tests to both `albums_controller_filters_spec.rb` and `tracks_controller_filters_spec.rb`; 573 total tests, 0 failures

### Frontend
- **AlbumGrid.js:** Added Epoch column (`epoch_name`, flex: 1) with list filter backed by epochs store
- **TrackGrid.js:** Added Epoch column (`epoch_name`, flex: 1) with list filter backed by epochs store
- **filtering.spec.js:** Added 4 new E2E tests (epoch column header + epoch list filter for both grids); fixed pre-existing bug in `setGridSearch`/`clearGridFilters` helpers where `grid.down('textfield')` matched the sort combobox on TrackGrid — narrowed to `textfield[emptyText]`

## Recent Changes (Apr 14, 2026) — Album Wikipedia/Notes, Edition Manager Fix, CreatableTag Fix

### Album Detail: Wikipedia & Notes Fields (Frontend Only)
- **AlbumDetail.js:** Added `wikipedia` textfield and `notes` textareafield after Tags field
- **AlbumController.js:** Added `wikipedia` and `notes` to the save payload
- No backend changes needed — fields already existed on Album model

### Edition Manager Dropdown Fix (Frontend Only)
- **EditionManagerController.js:** Rewrote `populateEditionSelector` to fetch ALL user editions from `GET /editions` API instead of only extracting editions from existing album tracks

### CreatableTag Trigger Fix (Frontend)
- **CreatableTag.js:** Changed trigger CSS to `x-form-create-trigger` (plus icon), handler to inline function
- **Application.scss:** Added FA5 plus glyph CSS rule

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

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
