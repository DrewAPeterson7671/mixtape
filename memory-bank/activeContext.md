# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 14, 2026) — Multi-Select and Multi-Edit

Added Ctrl/Shift multi-select and bulk-edit panels to Artist, Album, and Track grids. When 2+ records are selected, a multi-edit panel auto-shows in the side panel (card layout switch from detail panel).

### New Files (4)
- **`app/view/common/MultiEditPanel.js`** — Base class extending `Ext.form.Panel`. Provides `multiEditFields` config, `buildFieldItems()` (checkbox + field + optional mode combo per row), `loadRecords()` (pre-fills shared values, "(mixed values)" placeholder for differing), `getEnabledPayload()` (only opted-in fields)
- **`app/view/artists/ArtistMultiEdit.js`** — 6 fields: rating, complete, priority_id, phase_id, genre_ids, tag_ids
- **`app/view/albums/AlbumMultiEdit.js`** — 8 fields: release_type_id, year, medium_id, epoch_id, rating, listened, genre_ids, tag_ids (simplified, no tracklist)
- **`app/view/tracks/TrackMultiEdit.js`** — 6 fields: epoch_id, medium_id, rating, listened, genre_ids, tag_ids

### Modified Files (10)
- **3 Grid files:** Added `selModel: { mode: 'MULTI' }` and `bbar` status bar (total/selected counts)
- **3 Detail files:** Removed `title` config (now provided by wrapper panel)
- **3 View files:** Replaced direct detail panel with card-layout wrapper (`{entity}SidePanel`) containing both detail and multi-edit panels; added `selectionchange` listener
- **3 Controller files:** Added `init` (store load → updateStatusBar), `onSelectionChange`, `showMultiEdit`, `hideMultiEdit`, `onMultiEditSaveClick` (N parallel PUTs with "Add to" array merge), `onMultiEditCancelClick`, `updateStatusBar`; modified `onGridCellClick` (modifier key guard + sidePanel references), `onAddClick`, `onCancelClick`, `onSaveClick`, `doDelete` to use sidePanel wrapper

### Key Patterns
- Array fields (genre_ids, tag_ids) have "Replace" / "Add to" dropdown per field
- Checkbox opt-in per field — unchecked fields are disabled and won't be saved
- `.multi-edit-field-disabled` CSS class (opacity 0.4, pointer-events none) in `Application.scss`
- No backend changes — existing PUT endpoints accept partial updates

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 14:** Multi-select and multi-edit panels for Artist, Album, Track grids (4 new files, 10 modified)
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
