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
- [x] Lookup tables: Genre, Tag, Priority, Phase, Epoch, Medium, Edition, ReleaseType (per-user ownership via `UserOwnable` concern, `user_id NOT NULL`)
- [x] Epoch lookup with year_start, year_end, replay, weight fields for smart playlist support; assigned to UserAlbum and UserTrack; propagated from album to inline tracks
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
- [x] Full CRUD for all lookup tables (Genres, Tags, Priorities, Phases, Epochs, Media, Editions, ReleaseTypes) with per-user ownership (scoped through `current_user` associations)
- [x] CSRF skip on all JSON-serving controllers
- [x] CORS configured for frontend at localhost:1841 with `credentials: true`

### Controller Patterns
- [x] UserPreferable concern for find_or_initialize_by preference lookup
- [x] ExtJsFilterable concern for server-side column filters and text search on index actions
- [x] Transaction-wrapped create/update on catalog controllers
- [x] Genre/tag sync (destroy-missing + find_or_create) on all three catalog controllers
- [x] Preference pre-loading via `.index_by` on index actions
- [x] Delete removes user preference only (not catalog record) on catalog controllers
- [x] Index endpoints scoped to user's collection (only returns records user has preferences for)
- [x] Artist delete cascades to remove user's UserAlbum and UserTrack for that artist's albums/tracks
- [x] Playlist scoped through `current_user.playlists`
- [x] ArtistsController `artist_json` helper with ID fields for form population
- [x] ArtistsController saves preferences before genre/tag sync to avoid `pref.reload` data loss
- [x] AlbumsController saves preferences before genre/tag sync to avoid `pref.reload` data loss
- [x] AlbumsController `album_json` helper with ID fields for form population
- [x] TracksController saves preferences before genre/tag sync to avoid `pref.reload` data loss
- [x] TracksController `track_json` helper with ID arrays (artist_ids, album_ids) and preference data
- [x] TracksController handles album association via AlbumTrack in create/update
- [x] TracksController handles `album_ids` array sync via `handle_album_ids_association` (adds/removes AlbumTrack records as unsorted entries)
- [x] TracksController `sort_tracks` method with 6 sort options (`artist`, `album_artist`, `title`, `album`, `rating`, `recent`) via `params[:sort]`

### Ext.js Frontend
- [x] Artist CRUD: ArtistView (border layout), ArtistDetail (form panel), ArtistController (ViewController)
- [x] Star rating widget: reusable `StarRating` custom form field (`app/view/common/StarRating.js`)
- [x] Inline grid star rating with direct AJAX save (no full form submit needed)
- [x] `withCredentials: true` on all 11 stores and all 11 model proxies
- [x] All stores/models point to `http://localhost:3000` API

### Testing
- [x] RSpec configured with FactoryBot and Shoulda Matchers
- [x] Model specs for all 22 models (including uniqueness validations on all lookup models, `UserOwnable` shared examples for 8 lookup models)
- [x] Controller specs for all 15 controllers (including sessions, test_auth, application_controller, `PerUserLookup` shared examples for 8 lookup controllers)
- [x] Factories for all 22 models (user factory suppresses seed callback by default, `:with_default_lookups` trait for explicit testing)
- [x] Auth helper (`sign_in`) for controller specs
- [x] Transactional fixtures enabled
- [x] Sorting verification specs for artists, albums, tracks, genres index actions
- [x] 404 (RecordNotFound) specs for show/update/destroy on artists, albums, tracks, genres
- [x] Validation error (422) specs: invalid album year, duplicate genre name, duplicate scoped playlist name
- [x] ExtJsFilterable edge case specs: LIKE wildcard escaping, unknown operator fallthrough, empty list filter
- [x] Dedicated concern specs: UserPreferable (find-or-initialize, user isolation) and ExtJsFilterable helpers (parse_filters, sanitize_like, unknown kind fallthrough) in `spec/controllers/concerns/`

### Infrastructure
- [x] PostgreSQL on port 5433 for development
- [x] dotenv-rails for environment variable loading
- [x] GitHub Actions CI pipeline (scan_ruby, scan_js, lint, test jobs)
- [x] Brakeman security scanning
- [x] RuboCop linting
- [x] Health check endpoint (`/up`)
- [x] E2E testing infrastructure (Playwright in frontend repo, 252 tests across 34 spec files) with auth setup, smoke, navigation, album/artist/track view, CRUD tests, delete/cascade tests, ratings, preferences, associations, tracklist, duration field, edition filter, add-track-ux, inline-track-genre-medium, lookup entity CRUD (genres, media, phases, priorities, release types, editions), edition manager modal, playlists, tags, genre auto-populate, form validation, grid column sorting, tagfield interactions, cell-edit-gating, cancel-button, va-album-toggle, edition-management, filtering, lookup-sequence-definition, and creatable-tagfield
- [x] Playwright MCP server for Claude Code browser automation (`.mcp.json`)
- [x] Test auth endpoint (`POST /test/login`) for E2E auth bypass in dev/test environments
- [x] E2E cleanup endpoint (`DELETE /test/cleanup`) — user-scoped catalog cleanup via e2e@test.com join records + orphan detection, prefix matching only for lookups, transaction-wrapped, playlist cleanup included
- [x] Claude Code test sub-agents — backend RSpec agent and frontend E2E agent as slash commands in `.claude/commands/`
- [x] E2E test helpers — shared `extjs.js` utility module (waitForExtReady, navigateToView, navigateToSettingsView, fillTextField, clickButton, confirmDialog, waitForToast, waitForStoreRecord, selectGridRecord, clickToolbarButton, waitForStoreLoad, getGridRowCount, setFieldValue, getFieldValue, getRecordFieldValue, ensureRecordVisible, ComponentQuery wrappers)
- [x] Playwright MCP config in frontend repo (`.mcp.json`)
- [x] Test orchestrator slash commands — `test-full` (backend) and `e2e-full` (frontend) for single-invocation write/run/fix cycle
- [x] Branch guard hook — PreToolUse hook blocks Edit/Write on protected branches, forces working branch creation (both repos). Hook resolves branch from its own repo directory via `git -C` to work correctly across repos.
- [x] Lookup table grids — All 5 non-genre lookups (editions, media, phases, priorities, release_types) sort by `sequence ASC NULLS LAST, name ASC` with user-controlled sequence column; genres sort by name
- [x] Lookup sequence & definition — `sequence` integer on all 5 lookups for display ordering; `definition` text on phases/priorities for documenting meaning; frontend grids, forms, stores, and controllers all updated

### Documentation
- [x] CLAUDE.md with project context
- [x] .claudeignore for AI context filtering
- [x] README with project documentation
- [x] Memory bank documentation (projectBrief, dataModel, systemPatterns, techContext, activeContext, productContext)

## What Needs Fixing (Known Issues)

- [ ] CI test job runs `bin/rails test` (Minitest) instead of `bundle exec rspec`
- [ ] CI test job installs sqlite3 instead of configuring PostgreSQL service
- [ ] CI has no PostgreSQL service container for the test job
- [ ] Flaky E2E test: `edition-manager-modal.spec.js` — "save persists edition track assignments" intermittently fails (timing/race condition)
- [ ] Consistent E2E failure: `inline-track-genre-medium.spec.js` — "new inline row pre-populates genres" fails waiting for cell editor visibility (timing issue with Ext JS cell editor activation)
- [ ] Inconsistent JSON rendering (inline `as_json` vs `render json:` vs jbuilder views)
- [ ] Genre/tag sync logic duplicated across 3 controllers — not extracted to shared module
- [ ] `database.yml` contains stale commented-out SQLite configuration
- [ ] Dockerfile (if present) may reference sqlite3
- [ ] Orphaned jbuilder view files — 32 `.json.jbuilder` files exist under `app/views/` but are unused since all controllers render JSON directly

## What's Not Built Yet (Pending)

### Core New Features
- [x] **Inline track entry (Phase 1)** — Checkbox toggle in tracklist grid for bulk track name entry, artist inheritance, album-save transaction
- [x] **Edition management modal (Phase 2)** — Separate modal for organizing tracks into editions, dual-grid UI, save via `PUT /albums/:id/edition_tracks`, Copy To/Move To/Clear operations
- [ ] **CSV/streaming import (Phase 3)** — Import tracks from CSV files and streaming platforms with ISRC-based deduplication
- [ ] Smart playlists — dynamic playlist generation from combinations of attributes (e.g., least recently played tracks by artists starting with "B" in genre "Reggae" from phase "High School")
- [ ] CSV import/export for artists, albums, tracks, playlists, etc.
- [ ] Streaming platform integration — connect to Apple Music and Spotify to import artists/albums/tracks and export playlists
- [x] Search and filtering — ExtJsFilterable concern with server-side column filters (string, number, boolean, list, habtm_string, habtm_list) and text search on all catalog index endpoints; Ext JS gridfilters plugin + toolbar search on all grids
- [ ] Admin role/privileges — admin-level users who can delete catalog records (artists, albums, tracks) and manage lookup tables

### Frontend CRUD Rollout
- [x] Artist CRUD (grid + detail form + star rating) — template pattern for other entities
- [x] Album CRUD (grid + detail form + star rating + genre auto-populate from artists)
- [x] Track CRUD (TrackGrid, TrackDetail, TrackController — full CRUD following Artist/Album pattern)
- [ ] Playlist CRUD (copy Artist pattern, customize fields)
- [x] Lookup table CRUD (simpler single-field forms — editions, genres, media, phases, priorities, release types) with per-user ownership (all records freely editable/deletable)

### Infrastructure & Cleanup
- [ ] Pagination on list endpoints
- [ ] Serializer layer (replace inline `as_json` / jbuilder mix)
- [ ] Extract genre/tag sync into a shared concern or service
- [x] Lookup table access control (per-user ownership — every record belongs to one user, scoped through `current_user` associations)
- [x] Remove HTML views and `format.html` blocks — controllers now render JSON directly
