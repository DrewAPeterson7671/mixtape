# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 11, 2026) — Add Artist Attributes and Related Artists

Added 8 new text columns to the `artists` catalog table (`notes`, `wikipedia`, `official_page`, `bandcamp`, `last_fm`, `google_genre_link`, `all_music`, `all_music_discography`) and a self-referential `related_artists` HABTM relationship via a new `related_artists` join table.

- **Migration:** `20260411072328_add_attributes_and_related_artists_to_artists.rb` — 8 text columns + join table with dual unique indexes and foreign keys
- **Backend:** Updated model (HABTM), controller (`artist_params` + `artist_json`), ERB views, jbuilder, factory
- **Frontend:** Updated Artist model (10 new fields), ArtistDetail (9 form fields + tagfield for related artists, `labelWidth: 130`), ArtistController (save payload + setValue), ArtistGrid (9 hidden columns)
- **Specs:** New model association test, 4 new controller specs (create with attrs, update with attrs, set/clear related_artist_ids, show returns related fields)

## Recent Changes (Apr 11, 2026) — Rename Artist `wikipedia` to `wikipedia_discography`

Renamed the `wikipedia` column on the `artists` table to `wikipedia_discography` to better describe its purpose (links to Wikipedia discography pages, not general artist pages).

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
