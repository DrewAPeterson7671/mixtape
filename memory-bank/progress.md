# Progress

## What Works (Completed)

### Data Model
- [x] Catalog models: Artist, Album, Track with validations and relationships
- [x] Track data model refactored: HABTM artists (via `artists_tracks`), has_many albums through `AlbumTrack` join model, `duration`/`isrc` fields added
- [x] AlbumTrack join model with position/disc_number metadata (allows same track on multiple albums)
- [x] User preference join models: UserArtist, UserAlbum, UserTrack (all with `genre_name` helper)
- [x] Sub-join models for per-user genres: UserArtistGenre, UserAlbumGenre, UserTrackGenre
- [x] Sub-join models for per-user tags: UserArtistTag, UserAlbumTag, UserTrackTag
- [x] Scoped `has_many` lambda pattern on all preference models
- [x] Lookup tables: Genre, Tag, Priority, Phase, Medium, Edition, ReleaseType
- [x] Playlist model with HABTM to artists, tracks, tags
- [x] User model with `cognito_sub` unique identifier
- [x] All HABTM join tables with dual unique indexes (albums_artists, artists_tracks, artists_playlists, playlists_tracks, playlists_tags)
- [x] Foreign keys and uniqueness constraints across all join models

### Authentication
- [x] AWS Cognito OIDC integration via OmniAuth
- [x] Session-based auth with cookie store
- [x] `current_user` lookup from session in ApplicationController
- [x] Global `require_login` before_action
- [x] Login callback (`/auth/cognito/callback`)
- [x] Logout with Cognito redirect (`/logout`)
- [x] Auth status endpoint (`GET /auth/status`)
- [x] `Current.user` set for access outside controllers

### API Endpoints
- [x] Full CRUD for Artists (JSON API)
- [x] Full CRUD for Albums (JSON API)
- [x] Full CRUD for Tracks (JSON API)
- [x] Full CRUD for Playlists (user-scoped, JSON API)
- [x] Full CRUD for all lookup tables (Genres, Tags, Priorities, Phases, Media, Editions, ReleaseTypes)
- [x] CSRF skip on all JSON-serving controllers
- [x] CORS configured for frontend at localhost:1841 with `credentials: true`

### Controller Patterns
- [x] UserPreferable concern for find_or_initialize_by preference lookup
- [x] Transaction-wrapped create/update on catalog controllers
- [x] Genre/tag sync (destroy-missing + find_or_create) on all three catalog controllers
- [x] Preference pre-loading via `.index_by` on index actions
- [x] Delete removes user preference only (not catalog record) on catalog controllers
- [x] Playlist scoped through `current_user.playlists`
- [x] ArtistsController `artist_json` helper with ID fields for form population
- [x] ArtistsController saves preferences before genre/tag sync to avoid `pref.reload` data loss
- [x] AlbumsController saves preferences before genre/tag sync to avoid `pref.reload` data loss
- [x] AlbumsController `album_json` helper with ID fields for form population
- [x] TracksController saves preferences before genre/tag sync to avoid `pref.reload` data loss
- [x] TracksController `track_json` helper with ID arrays (artist_ids, album_ids) and preference data
- [x] TracksController handles album association via AlbumTrack in create/update

### Ext.js Frontend
- [x] Artist CRUD: ArtistView (border layout), ArtistDetail (form panel), ArtistController (ViewController)
- [x] Star rating widget: reusable `StarRating` custom form field (`app/view/common/StarRating.js`)
- [x] Inline grid star rating with direct AJAX save (no full form submit needed)
- [x] `withCredentials: true` on all 11 stores and all 11 model proxies
- [x] All stores/models point to `http://localhost:3000` API

### Testing
- [x] RSpec configured with FactoryBot and Shoulda Matchers
- [x] Model specs for all 21 models
- [x] Controller specs for all 13 controllers (including sessions)
- [x] Factories for all 21 models
- [x] Auth helper (`sign_in`) for controller specs
- [x] Transactional fixtures enabled

### Infrastructure
- [x] PostgreSQL on port 5433 for development
- [x] dotenv-rails for environment variable loading
- [x] GitHub Actions CI pipeline (scan_ruby, scan_js, lint, test jobs)
- [x] Brakeman security scanning
- [x] RuboCop linting
- [x] Health check endpoint (`/up`)
- [x] E2E testing infrastructure (Playwright in frontend repo) with auth setup, smoke, navigation, and album tests
- [x] Playwright MCP server for Claude Code browser automation (`.mcp.json`)
- [x] Test auth endpoint (`POST /test/login`) for E2E auth bypass in dev/test environments

### Documentation
- [x] CLAUDE.md with project context
- [x] .claudeignore for AI context filtering
- [x] README with project documentation
- [x] Memory bank documentation (projectBrief, dataModel, systemPatterns, techContext, activeContext, productContext)

## What Needs Fixing (Known Issues)

- [ ] CI test job runs `bin/rails test` (Minitest) instead of `bundle exec rspec`
- [ ] CI test job installs sqlite3 instead of configuring PostgreSQL service
- [ ] CI has no PostgreSQL service container for the test job
- [ ] Inconsistent JSON rendering (inline `as_json` vs `render json:` vs jbuilder views)
- [ ] Genre/tag sync logic duplicated across 3 controllers — not extracted to shared module
- [ ] `database.yml` contains stale commented-out SQLite configuration
- [ ] Dockerfile (if present) may reference sqlite3
- [ ] Orphaned jbuilder view files — 32 `.json.jbuilder` files exist under `app/views/` but are unused since all controllers render JSON directly

## What's Not Built Yet (Pending)

### Completed Recently
- [x] Default edition per album — `default_edition_id` on UserAlbum (nullable FK to editions), auto-selects in edition filter on album load, "Default Edition" checkbox in tracklist tbar with save/clear via PUT, sync with edition filter changes
- [x] Edition management modal (Phase 2) — Backend `PUT /albums/:id/edition_tracks` endpoint with disc_number validation and transaction logic. Frontend `EditionManagerModal` + `EditionManagerController` with edition selector, dual grids (edition tracks + available tracks), add/remove/reorder, save via API, dirty tracking, and edition operations (Create New, Copy To, Move To, Clear). "Manage Editions" button in AlbumDetail tracklist tbar, visibility toggled by `consider_editions`.
- [x] Inline track entry (Phase 1) — checkbox toggle, artist inheritance, genre transfer, duration/ISRC, entry mode, album-save transaction, `handle_album_tracks`/`create_inline_track`/`copy_album_genres_to_track`/`resolve_duplicate_title` in AlbumsController
- [x] Track CRUD frontend — TrackGrid, TrackDetail, TrackController with full CRUD following Artist/Album template pattern
- [x] `consider_editions` toggle — backend boolean on UserAlbum + frontend checkbox with edition UI visibility
- [x] DurationField custom widget — `app/view/common/DurationField.js`, m:ss parsing in tracklist grid and track detail
- [x] `various_artists` boolean on Album — catalog-level flag, JSON artist_name override, frontend checkbox with artist field toggle
- [x] Duplicate album title fix — `Track#album_title` uses `.distinct` for multi-edition tracks

### Core New Features
- [x] **Inline track entry (Phase 1)** — Checkbox toggle in tracklist grid for bulk track name entry, artist inheritance, album-save transaction
- [x] **Edition management modal (Phase 2)** — Separate modal for organizing tracks into editions, dual-grid UI, save via `PUT /albums/:id/edition_tracks`, Copy To/Move To/Clear operations
- [ ] **CSV/streaming import (Phase 3)** — Import tracks from CSV files and streaming platforms with ISRC-based deduplication
- [ ] Smart playlists — dynamic playlist generation from combinations of attributes (e.g., least recently played tracks by artists starting with "B" in genre "Reggae" from phase "High School")
- [ ] CSV import/export for artists, albums, tracks, playlists, etc.
- [ ] Streaming platform integration — connect to Apple Music and Spotify to import artists/albums/tracks and export playlists
- [ ] Search and filtering — extensive backend filtering/search on index actions
- [ ] Admin role/privileges — admin-level users who can delete catalog records (artists, albums, tracks) and manage lookup tables

### Frontend CRUD Rollout
- [x] Artist CRUD (grid + detail form + star rating) — template pattern for other entities
- [x] Album CRUD (grid + detail form + star rating + genre auto-populate from artists)
- [x] Track CRUD (TrackGrid, TrackDetail, TrackController — full CRUD following Artist/Album pattern)
- [ ] Playlist CRUD (copy Artist pattern, customize fields)
- [x] Lookup table CRUD (simpler single-field forms — editions, genres, media, phases, priorities, release types)

### Infrastructure & Cleanup
- [ ] Pagination on list endpoints
- [ ] Serializer layer (replace inline `as_json` / jbuilder mix)
- [ ] Extract genre/tag sync into a shared concern or service
- [ ] Lookup table access control (admin-only create/delete)
- [x] Remove HTML views and `format.html` blocks — controllers now render JSON directly
