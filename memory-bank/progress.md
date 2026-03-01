# Progress

## What Works (Completed)

### Data Model
- [x] Catalog models: Artist, Album, Track with validations and relationships
- [x] User preference join models: UserArtist, UserAlbum, UserTrack
- [x] Sub-join models for per-user genres: UserArtistGenre, UserAlbumGenre, UserTrackGenre
- [x] Sub-join models for per-user tags: UserArtistTag, UserAlbumTag, UserTrackTag
- [x] Scoped `has_many` lambda pattern on all preference models
- [x] Lookup tables: Genre, Tag, Priority, Phase, Medium, Edition, ReleaseType
- [x] Playlist model with HABTM to artists, tracks, tags
- [x] User model with `cognito_sub` unique identifier
- [x] All HABTM join tables with dual unique indexes
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
- [ ] TracksController `update` action has same `pref.reload` bug — `save!` should come before genre/tag sync
- [ ] `database.yml` contains stale commented-out SQLite configuration
- [ ] Dockerfile (if present) may reference sqlite3

## What's Not Built Yet (Pending)

### Core New Features
- [ ] Smart playlists — dynamic playlist generation from combinations of attributes (e.g., least recently played tracks by artists starting with "B" in genre "Reggae" from phase "High School")
- [ ] CSV import/export for artists, albums, tracks, playlists, etc.
- [ ] Streaming platform integration — connect to Apple Music and Spotify to import artists/albums/tracks and export playlists
- [ ] Search and filtering — extensive backend filtering/search on index actions
- [ ] Admin role/privileges — admin-level users who can delete catalog records (artists, albums, tracks) and manage lookup tables

### Frontend CRUD Rollout
- [x] Artist CRUD (grid + detail form + star rating) — template pattern for other entities
- [x] Album CRUD (grid + detail form + star rating + genre auto-populate from artists)
- [ ] Track CRUD (copy Artist pattern, customize fields)
- [ ] Playlist CRUD (copy Artist pattern, customize fields)
- [ ] Lookup table CRUD (simpler single-field forms)

### Infrastructure & Cleanup
- [ ] Pagination on list endpoints
- [ ] Serializer layer (replace inline `as_json` / jbuilder mix)
- [ ] Extract genre/tag sync into a shared concern or service
- [ ] Lookup table access control (admin-only create/delete)
- [x] Remove HTML views and `format.html` blocks — controllers now render JSON directly
