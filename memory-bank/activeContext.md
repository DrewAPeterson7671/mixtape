# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 12, 2026) — Epoch Lookup Entity

Added Epoch as a new per-user lookup entity for tagging albums and tracks with the time period when the user first discovered that music. Supports future smart playlist features (replay frequency, weighted selection).

### Backend
- **Migration:** `CreateEpochs` — `name` (string, NOT NULL), `sequence` (int), `definition` (text), `year_start` (int), `year_end` (int), `replay` (int), `weight` (int), `user_id` (bigint, NOT NULL FK); unique index on `[name, user_id]`
- **Migration:** `AddEpochIdToUserAlbumsAndUserTracks` — nullable FK `epoch_id` on both tables
- **Inflection:** Added `inflect.irregular "epoch", "epochs"` (Rails pluralizes as "epoches" by default)
- **Model:** `Epoch` with `UserOwnable` concern (same as Phase)
- **Controller:** `EpochsController` — full CRUD, permits all 7 columns, `sequence ASC NULLS LAST, name ASC` ordering
- **UserAlbum/UserTrack:** Added `belongs_to :epoch, optional: true` and `epoch_name` helper
- **AlbumsController:** `epoch_id` in `preference_params`; `epoch_id`/`epoch_name` in `album_json` response and each track entry; epoch propagation from album to inline tracks via `copy_album_epoch_to_track`; `:epoch` in `.includes`
- **TracksController:** `epoch_id` in `preference_params`; `epoch_id`/`epoch_name` in `track_json`; `:epoch` in `.includes`
- **TestCleanupController:** Added `epochs: Epoch` to lookup cleanup hash
- **Routes:** Added `resources :epochs`
- **Specs:** 31 tests (model + controller) all passing; full suite 571 tests, 0 failures

### Frontend
- **Model/Store:** `Epoch.js` model (all 7 columns + timestamps), `Epochs.js` store with sequence/name sorter
- **Settings views:** `EpochGrid.js` (columns: #, Name, Definition, Years renderer, Replay, Weight), `EpochDetail.js` (form with all 7 fields), `EpochView.js` (border layout), `EpochController.js` (CRUD)
- **Main.js:** Added Epochs to Settings nav tree and switch case
- **Album.js/Track.js models:** Added `epoch_id` (int, allowNull) and `epoch_name` fields
- **AlbumDetail.js:** Epoch combobox on form (after Medium), `epoch_id`/`epoch_name` in tracklist grid store fields, Epoch column with combobox editor
- **AlbumController.js:** `epoch_id` in save payload and inline track entries; `epoch_id` setValue on load; epoch pre-population in `addInlineTrackRow`; `epoch_id` editable in entry mode; `epoch_name` sync on cell edit
- **TrackDetail.js:** Epoch combobox (after Albums, before Medium)
- **TrackController.js:** `epoch_id` in save payload; `epoch_id` setValue on load

## Earlier (Apr 12, 2026) — CreatableTagField & E2E Tests

Added `CreatableTag` component and Playwright E2E tests for inline entity creation. See git history for details.

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

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
