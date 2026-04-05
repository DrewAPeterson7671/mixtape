# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 5, 2026) — Tracklist Column Visibility & Track Data from Show Endpoint

- **Frontend: ISRC, Listened, Rating, Genres columns now visible by default** — Removed `hidden: true` from these four tracklist columns. Edition column set to `hidden: true` by default (still toggled by `consider_editions` via `updateEditionVisibility`).
- **Frontend: Tracklist fetches from show endpoint** — `onGridCellClick` now makes a `GET /albums/:id` request to populate the tracklist instead of using `record.get('album_tracks')` from the index response. The index passes `{}` for user track prefs, so listened/rating/genres were always blank. The show endpoint loads full `UserTrack` records with genres/tags. Fresh data is written back to the grid record for use by `onConsiderEditionsChange` and other handlers.
- **Frontend: Entry mode no longer toggles column visibility** — `onEntryModeChange` just sets the `entryMode` flag; editability is already gated by `onBeforeEdit`.
- **Backend: `album_json` includes genre/tag data per track** — Added `genre_ids`, `genre_name`, `tag_ids`, `tag_name` to the per-track hash and `.includes(:genres, :tags)` on user_tracks queries.
- **Frontend: Genre column renderer fixed** — Changed from failed `Ext.getStore('genres')` lookup to reading `genre_name` directly from the record. Added `genre_name` to store fields. `onCellEdit` syncs `genre_name` when genres edited. `addInlineTrackRow` populates `genre_name` alongside `genre_ids`.
- **Branches:** Backend `mixtape-develop-20260405_track_genre_names`, Frontend `mixtape-dev-20260405_track_genre_names`

## Recent Changes (Apr 4, 2026) — anyMatch on Artist & Track Typeaheads

- **Frontend: `anyMatch: true` on all artist/track typeahead components** — Users can now type any part of an artist or track name to find a match (e.g., "Smashing" finds "The Smashing Pumpkins"). Applied to 5 components:
  1. Album Detail artist tagfield (`AlbumDetail.js`)
  2. Track Detail artist tagfield (`TrackDetail.js`)
  3. Inline tracklist title typeahead combobox (`AlbumDetail.js`)
  4. Inline tracklist artist column combobox (`AlbumDetail.js`)
  5. Add Track modal track combobox (`AlbumController.js`)
- **Branch:** `mixtape-dev-20260404_anyMatch_artist_typeahead`

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
