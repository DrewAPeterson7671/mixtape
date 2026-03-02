# Active Context

## Current Branch

`mixtape-dev-tracks_controller` — Track data model refactor branch.

## Recent Changes (Mar 2026)

- **Track data model refactor** — Major restructure of the Track model to support multiple artists and multiple albums per track:
  - Track `belongs_to :artist` replaced with HABTM `artists` (via `artists_tracks` join table, matching the Album/Artist pattern)
  - Track `belongs_to :album` replaced with `has_many :albums, through: :album_tracks` via new `AlbumTrack` join model (carries `position` and `disc_number` metadata)
  - Removed `artist_id`, `album_id`, `number`, `disc_number` columns from `tracks` table
  - Added `duration` (integer, seconds) and `isrc` (string, indexed) columns to `tracks` for future deduplication during CSV/streaming imports
  - `artist_name` and `album_title` now return arrays instead of single values
  - Data migrated from old columns to new join tables via reversible migrations
  - 6 migrations total: create `artists_tracks`, create `album_tracks`, add duration/isrc, migrate artist data, migrate album data, remove old columns
- **TracksController refactor** — Updated to match new data model:
  - `track_params` now permits `artist_ids: []`, `:duration`, `:isrc` (removed old column params)
  - Includes changed from `:artist, :album` to `:artists, :albums`
  - Added `handle_album_association` for creating/updating `AlbumTrack` records
  - Fixed pref.reload bug: `save!` now called before genre/tag sync (matching Artists/Albums pattern)
  - Extracted `track_json` helper method (matching `artist_json`/`album_json` pattern) with full ID arrays and preference data
- **UserTrack genre_name method** — Added missing `genre_name` method to `UserTrack` model (was already present on `UserAlbum` and `UserArtist`)
- **New AlbumTrack model** — Join model with `belongs_to :album`, `belongs_to :track`, uniqueness validation, and spec/factory
- **Updated specs** — Track spec, Artist spec, Track factory, TracksController spec all updated for new associations

### Earlier in Mar 2026
- **Album CRUD frontend** — Full create/update/delete UI for Albums in Ext.js, following the Artist template pattern. AlbumView (border layout), AlbumDetail (form panel), AlbumController (ViewController). Includes genre auto-populate from selected artists on new albums.
- **Album preference save order fix** — In AlbumsController `update`, moved `@user_pref.save!` before `update_album_genres`/`update_album_tags` to prevent `pref.reload` from discarding unsaved rating/listened changes. Same fix previously applied to ArtistsController.
- **Genre auto-populate** — When adding a new album, selecting artists auto-populates the genre tagfield with the union of those artists' genre_ids. Implemented via `change` listener on the artist_ids tagfield routing to `onArtistChange` in AlbumController. Only fires in phantom (new album) mode.
- **Explicit setValue after loadRecord** — Added explicit `ratingField.setValue()` calls after `form.loadRecord()` in both AlbumController and ArtistController, since `loadRecord` doesn't reliably set values on custom `Ext.form.field.Base` subclasses (StarRating) or tagfields.
- **Duplicate reference fix** — Removed unused `reference: 'mainContent'` from the center panel in Main.js. The `removeAll()`/`add()` navigation pattern triggered `[W] Duplicate reference` warnings during Ext JS's asynchronous reference cleanup.

## Older Changes (Feb 2026)

- **Artist CRUD frontend** — Full create/update/delete UI for Artists in Ext.js. Border layout with grid (center) and collapsible detail form panel (east). Uses `Ext.Ajax.request` with `jsonData` for full payload control. Designed as a reusable template pattern for other entities.
- **Star rating widget** — Reusable `StarRating` custom form field (`app/view/common/StarRating.js`) using FontAwesome 5 `fas fa-star` / `far fa-star` icons. Clickable stars in both the grid (inline save via AJAX) and detail form. Gold for filled, gray for empty.
- **JSON-only controllers** — Removed all `respond_to` blocks, `format.html` handlers, and `new`/`edit` actions from all 11 resource controllers. All endpoints now render JSON directly.
- **CORS credentials** — Added `credentials: true` to `cors.rb` and `withCredentials: true` to all Ext.js store/model proxies for cross-origin session cookies.
- **Preference save order fix** — In ArtistsController `update`, moved `@user_pref.save!` before `update_artist_genres`/`update_artist_tags` to prevent `pref.reload` from discarding unsaved attribute changes (rating, complete, priority, phase).
- **Backend JSON IDs** — ArtistsController now includes `priority_id`, `phase_id`, `genre_ids`, `tag_ids`, `tag_name` in JSON responses via `artist_json` helper.
- **User preference refactor** — Moved per-user metadata (ratings, genres, tags, listening flags) out of catalog models and into dedicated join models (UserArtist, UserAlbum, UserTrack) with sub-join models for genres and tags.
- **AWS Cognito integration** — Added OmniAuth OIDC authentication with Cognito, replacing any previous auth approach. Session-based with cookie store.
- **Minitest to RSpec migration** — Replaced Minitest with RSpec, FactoryBot, and Shoulda Matchers. Added model and controller specs.

## Known Issues

- **CI runs Minitest, not RSpec** — The GitHub Actions workflow still runs `bin/rails test test:system` instead of `bundle exec rspec`. Tests pass locally with RSpec but CI is running the wrong test framework.
- **CI installs sqlite3** — The `test` job in `ci.yml` runs `apt-get install sqlite3`, which is unnecessary since the project uses PostgreSQL. No PostgreSQL service is configured in CI either.
- **Inconsistent JSON rendering** — Catalog controllers use inline `as_json(only: [...]).merge(...)`. Lookup controllers use `render json: { data: @model }`. No serializer layer.
- **No pagination** — All list endpoints return every record. Will become a problem as the catalog grows.
- **No backend filtering/search** — Index endpoints return all records; filtering happens client-side only.
- **Genre/tag sync duplication** — The `update_*_genres` and `update_*_tags` methods are copy-pasted across ArtistsController, AlbumsController, and TracksController with only model name differences.
- **Dockerfile references sqlite3** — The production Dockerfile (if present) may install sqlite3, a leftover from the Rails scaffold before PostgreSQL migration.
- **database.yml has stale SQLite comments** — The config file still contains commented-out SQLite configuration blocks.

## Open Questions

- **Lookup table access control** — Genre, Tag, Priority, Phase, Medium, Edition, and ReleaseType controllers have no authorization checks beyond `require_login`. Any authenticated user can create/delete lookup records that affect everyone. Should these be admin-only?
- ~~**HTML view removal**~~ — Done. All controllers now render JSON directly without `respond_to` blocks. The `new` and `edit` actions have been removed.
- **Artist, Album and Track deletion by Users** - It is likely that those classes will need need to be edited or deleted over time, perhaps only be an admin level user?
- **Create of Admin priveleges** - There are probably many reasons this will be needed.
