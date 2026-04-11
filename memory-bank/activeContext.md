# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 10, 2026) — Add `notes` and `wikipedia` to Albums

Added two optional text columns (`notes`, `wikipedia`) to the shared `albums` catalog table for free-form notes and Wikipedia URLs.

- **Migration:** `20260411065021_add_notes_and_wikipedia_to_albums.rb` — two nullable `text` columns
- **Controller:** `albums_controller.rb` — added to `album_params` permit list and `album_json` serialization
- **Tests:** 2 new specs (create + update) in `albums_controller_spec.rb`; 37 controller specs pass

## Recent Changes (Apr 10, 2026) — Propagate Artist Genres to Albums/Tracks

Created rake task `data:copy_artist_genres_to_albums_and_tracks` to recover album/track genre associations lost during the `make_lookup_user_id_not_null` migration.

## Recent Changes (Apr 9, 2026) — Editable Track Artists + Track Grid Sort Selector

Made the Artist column editable for all non-VA albums in entry mode (previously VA-only), and added a sort selector dropdown to the Track grid.

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
