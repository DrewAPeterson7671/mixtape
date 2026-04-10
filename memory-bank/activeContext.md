# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 9, 2026) — Editable Track Artists + Track Grid Sort Selector

Made the Artist column editable for all non-VA albums in entry mode (previously VA-only), and added a sort selector dropdown to the Track grid.

- **Backend branch:** `mixtape-develop-20260409_editable_track_artists_sort_selector`
- **Frontend branch:** `mixtape-dev-20260409_editable_track_artists_sort_selector`
- **TracksController:** New `sort_tracks` private method accepting `params[:sort]` with 6 options: `artist` (default), `album_artist`, `title`, `album`, `rating`, `recent`. Updated eager loading to include `{ albums: :artists }` and `:album_tracks` for N+1-safe sorting.
- **AlbumDetail.js:** Artist column changed from `combobox` (single-select on `artist_name`) to `tagfield` (multi-select on `artist_ids`), matching the genre column pattern.
- **AlbumController.js:** Removed VA-only restriction on artist editing — now editable for all `is_new` rows in entry mode. Pre-populates `artist_ids`/`artist_name` from album artist for non-VA albums. Updated `onCellEdit` and `onBeforeEdit` for `artist_ids` field. Save handler sends `artist_ids` for all new inline tracks (not just VA).
- **TrackGrid.js:** Sort combobox added to toolbar (6 sort options).
- **TrackController.js:** `onSortChange` handler sends `sort` param to backend and reloads store.
- **Tests:** 18 existing tracks controller specs pass (0 failures).

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
