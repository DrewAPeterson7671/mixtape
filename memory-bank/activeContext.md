# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 8, 2026) — Restore Missing UserAlbum and UserTrack Join Records

The `make_lookup_user_id_not_null` migration (Apr 6) deleted UserAlbum rows when their `default_edition_id` pointed to a system edition that couldn't be reassigned, making those albums invisible in the UI. UserTracks may also have been missing.

- **Migration** (`20260408015602_restore_missing_user_albums_and_tracks.rb`): data-only migration that `INSERT ... SELECT` cross-joins users × albums and users × tracks, with `NOT EXISTS` + `ON CONFLICT DO NOTHING` for idempotent gap-filling
- **Defaults**: `rating` NULL, `listened` false, `consider_editions` false, `default_edition_id` NULL
- **Result**: all 36 UserAlbum records (3 users × 12 albums) and 330 UserTrack records (3 users × 110 tracks) confirmed present, zero gaps
- **Tests**: 525 RSpec tests pass, no regressions

## Recent Changes (Apr 7, 2026) — Sequence and Definition Columns on Lookup Entities

Added `sequence` (integer, nullable) column to all 5 lookup entities (editions, media, phases, priorities, release_types) for user-controlled display ordering. Added `definition` (text, nullable) column to phases and priorities for documenting personal meaning.

**Branches:** Backend `mixtape-develop-20260407_add_sequence_definition_to_lookups`, Frontend `mixtape-dev-20260407_add_sequence_definition_to_lookups`

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

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
