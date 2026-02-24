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
- [x] Full CRUD for Artists (JSON + HTML)
- [x] Full CRUD for Albums (JSON + HTML)
- [x] Full CRUD for Tracks (JSON + HTML)
- [x] Full CRUD for Playlists (user-scoped, JSON + HTML)
- [x] Full CRUD for all lookup tables (Genres, Tags, Priorities, Phases, Media, Editions, ReleaseTypes)
- [x] CSRF skip on all JSON-serving controllers
- [x] CORS configured for frontend at localhost:1841

### Controller Patterns
- [x] UserPreferable concern for find_or_initialize_by preference lookup
- [x] Transaction-wrapped create/update on catalog controllers
- [x] Genre/tag sync (destroy-missing + find_or_create) on all three catalog controllers
- [x] Preference pre-loading via `.index_by` on index actions
- [x] Delete removes user preference only (not catalog record) on catalog controllers
- [x] Playlist scoped through `current_user.playlists`

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
- [ ] `database.yml` contains stale commented-out SQLite configuration
- [ ] Dockerfile (if present) may reference sqlite3

## What's Not Built Yet (Pending)

<!-- Edit this section with your planned work -->

- [ ] Pagination on list endpoints
- [ ] Backend filtering/search on index actions
- [ ] Serializer layer (replace inline `as_json` / jbuilder mix)
- [ ] Extract genre/tag sync into a shared concern or service
- [ ] Lookup table access control (admin-only create/delete?)
- [ ] Remove HTML views and `format.html` blocks if frontend is primary UI
- [ ]
- [ ]
- [ ]
