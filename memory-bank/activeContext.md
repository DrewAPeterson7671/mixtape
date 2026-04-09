# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 8, 2026) — Album Title Uniqueness Per Artist

Deleted duplicate "Movement" album (Album #1, empty — no tracks/genres/tags) that duplicated Album #4 (the real one with 8 tracks). Added `title_unique_per_artist` custom validation to `Album` model to prevent recurrence.

- **Backend branch:** `mixtape-develop-20260408_fix_edition_data`
- **Data cleanup:** Removed 3 UserAlbum records, 1 albums_artists join, and Album #1 via `rails runner`
- **Validation:** Case-insensitive title uniqueness scoped per artist (non-VA) or across all VA albums (VA). VA and non-VA albums can share a title.
- **Specs:** 6 model specs + 1 controller spec added (532 total, 0 failures)

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
