# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

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

## Recent Changes (Apr 1, 2026) — Inline Track Genre Column & Medium Inheritance

- **Backend: Inline tracks inherit `medium_id` from album** — `create_inline_track` in `AlbumsController` now passes `medium_id: @album.medium_id` to `Track.create!`, so tracks created via "Enter Track Names" entry mode automatically receive the album's medium type.
- **Backend: Per-track `genre_ids` on inline tracks** — `create_inline_track` now checks for `at_params[:genre_ids]`. When present, creates `UserTrackGenre` records from the submitted IDs instead of copying from the album. Falls back to `copy_album_genres_to_track` when absent (preserving existing behavior).
- **Frontend: Genre tagfield column in tracklist grid** — New `genre_ids` store field and hidden "Genres" column (with tagfield editor and genre name renderer) added to the Album Detail tracklist grid. Column visibility toggled alongside ISRC/Listened/Rating when "Enter Track Names" entry mode is enabled.
- **Frontend: Genre editing gated to new rows** — `onBeforeEdit` allows `genre_ids` editing only on `is_new` rows when entry mode is on (same rule as duration/isrc).
- **Frontend: Genre pre-population on new rows** — `addInlineTrackRow` reads the album's VA status and genre_ids field. Non-VA albums: new rows pre-populated with album genres. VA albums: new rows start with empty genres.
- **Frontend: `genre_ids` in save payload** — The `onSaveClick` method includes `genre_ids` in the inline track entry object sent to the backend.
- **Branches:** Backend `mixtape-develop-20260401_inline_track_genre_medium`, Frontend `mixtape-dev-20260401_inline_track_genre_column`
- **Backend tests:** 348 examples, 0 failures (2 new: medium_id inheritance, per-track genre_ids override).
- **E2E tests:** New `e2e/inline-track-genre-medium.spec.js` with 8 tests in 2 serial suites.

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
