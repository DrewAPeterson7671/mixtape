# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 8, 2026) — Pre-populate Empty Tracklist in Entry Mode

When toggling "Enter Track Names" on an album with no tracks, 8 empty rows are now auto-created to reduce friction for new album data entry.

- **Frontend branch:** `mixtape-dev-20260408_prepopulate_tracklist_rows`
- **File:** `AlbumController.js` — `onEntryModeChange` checks `if (checked && store.getCount() === 0)` and calls `addInlineTrackRow()` 8 times
- **Bulk-add guard:** `this._bulkAdding` flag suppresses auto-edit focus during the loop; cleared after. `addInlineTrackRow` skips `startEditByPosition` when flag is set, preserving single-row auto-focus behavior for the "Add Track" button

## Recent Changes (Apr 8, 2026) — Fix Edition Data on 3 Albums

Three albums had triplicated `album_track` rows with all `edition_id` values set to `nil` (leftover from the edition migration refactor). Fixed via `rails runner` script — data-only change, no source files modified.

- **Ride The Lightning:** Original Release (8 tracks) + Ultimate Edition (10 tracks, default), 8 duplicate rows deleted
- **Low-Life:** Original Release (8 tracks, fixed broken disc/position data) + Deluxe Edition (16 tracks, default), 8 duplicate rows deleted
- **Power, Corruption & Lies:** Original Release (8 tracks) + Definitive Edition (10 tracks) + Deluxe Edition (16 tracks, default), no deletions needed
- All three albums now have `consider_editions=true` with most complete edition as default
- UserTrack records (ratings, listened) unaffected — keyed by track_id, not album_track

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 8:** Restore missing UserAlbum/UserTrack join records via data migration
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
