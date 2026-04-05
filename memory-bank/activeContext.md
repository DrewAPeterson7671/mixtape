# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 5, 2026) — Track Genre/Tag Names in Album Detail

- **Backend: `album_json` now includes genre and tag data per track** — The `album_tracks` array in the album detail response was missing `genre_ids`, `genre_name`, `tag_ids`, and `tag_name` for each track. Added these fields from `user_track_pref` and added `.includes(:genres, :tags)` to eager-load the associations (avoiding N+1 queries).
- **Frontend: Genre column renderer fixed** — The tracklist genre column renderer was calling `Ext.getStore('genres')` to look up a global store that didn't exist, causing raw IDs to fall through. Changed to read `genre_name` directly from the record (matching how `AlbumGrid` and `TrackGrid` already work). Added `genre_name` to the tracklist store fields.
- **Frontend: Genre name sync on edit and new rows** — `onCellEdit` now syncs `genre_name` when `genre_ids` is changed via the tagfield editor. `addInlineTrackRow` now populates `genre_name` alongside `genre_ids` when inheriting from album genres.
- **Branches:** Backend `mixtape-develop-20260405_track_genre_names`, Frontend `mixtape-dev-20260405_track_genre_names`

## Recent Changes (Apr 4, 2026) — anyMatch on Artist & Track Typeaheads

- **Frontend: `anyMatch: true` on all artist/track typeahead components** — Users can now type any part of an artist or track name to find a match (e.g., "Smashing" finds "The Smashing Pumpkins"). Applied to 5 components:
  1. Album Detail artist tagfield (`AlbumDetail.js`)
  2. Track Detail artist tagfield (`TrackDetail.js`)
  3. Inline tracklist title typeahead combobox (`AlbumDetail.js`)
  4. Inline tracklist artist column combobox (`AlbumDetail.js`)
  5. Add Track modal track combobox (`AlbumController.js`)
- **Branch:** `mixtape-dev-20260404_anyMatch_artist_typeahead`

## Recent Changes (Apr 3–4, 2026) — Default Listing Order for Index Endpoints

- **Artists index ordered alphabetically** — Ruby-level `.sort_by` in `ArtistsController#index` with article stripping (`/^(The|A|An)\s+/i`), so "The Beatles" sorts under B.
- **Albums index ordered by artist then title** — Ruby-level `.sort_by` after eager-loading in `AlbumsController#index`. Sorts by first artist name (with article stripping), then album title. VA albums use "various artists" as sort key so they sort under V instead of floating to top. Ruby sorting used because albums have a many-to-many (HABTM) relationship with artists, making SQL-level ordering with aggregation complex alongside the existing `.distinct` and filter joins.
- **Tracks index ordered by artist, album, track** — Ruby-level `.sort_by` after eager-loading in `TracksController#index`. Sorts by first artist name (with article stripping), then first album title, then track title. Same HABTM reasoning as albums.
- **Article prefix stripping** — Artist names starting with "The", "A", or "An" (case-insensitive) are sorted by the remainder of the name. Applied consistently to the artist name component of sorting in all three catalog controllers.
- **Unsorted album tracks sort last** — Tracks with no position or disc_number now sort after positioned tracks (alphabetically by title), instead of floating to the top as `[0, 0]`.
- **Removed `.order(:name)` from lookup table controllers** — Editions, Phases, Priorities, and Release Types index actions no longer sort alphabetically. They return in default database order (primary key / insertion order). Genres and Media were not changed.
- **Branch:** `mixtape-develop-20260403_default_listing_order`
- **Tests:** 348 examples, 0 failures (no changes to test suite).

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 1:** Safer E2E test cleanup strategy (user-scoped catalog record cleanup, orphan detection, transaction wrapping)
- **Mar 30:** Add Track UX improvements (`title_with_artist` display, artist filtering, `album_ids` sync)
- **Mar 29:** E2E tests for duration field & edition filter, DurationField double-conversion bug fix, branch guard hook fix
- **Mar 28:** Server-side grid filtering & search via `ExtJsFilterable` concern (6 filter kinds, text search, all 3 catalog controllers)
- **Mar 27:** Non-CRUD E2E tests (ratings, preferences, associations, tracklist), `primary_key` bug fix on UserArtist/UserTrack
- **Mar 25:** Collection-scoped index endpoints, artist cascade delete, delete & cascade E2E tests
- **Mar 24:** CRUD E2E tests for artists, albums, tracks
- **Mar 22:** Playwright E2E infrastructure, test sub-agents, test orchestrator commands
- **Mar 13:** Default edition per album (`default_edition_id` on UserAlbum)
- **Mar 12:** Edition management modal (Phase 2)
- **Mar 10-11:** Inline track creation (Phase 1), Track CRUD frontend, `consider_editions` toggle, DurationField, `various_artists` boolean
- **Earlier Mar:** Track data model refactor (HABTM artists, AlbumTrack join model), Album CRUD frontend, genre auto-populate
- **Feb:** Artist CRUD frontend, star rating widget, JSON-only controllers, user preference refactor, Cognito auth, RSpec migration
