# Active Context

## Current Branch

`mixtape-develop-current_user` — development branch for current user scoping and preference features.

## Recent Changes (Feb 2026)

- **User preference refactor** — Moved per-user metadata (ratings, genres, tags, listening flags) out of catalog models and into dedicated join models (UserArtist, UserAlbum, UserTrack) with sub-join models for genres and tags.
- **AWS Cognito integration** — Added OmniAuth OIDC authentication with Cognito, replacing any previous auth approach. Session-based with cookie store.
- **Auth status endpoint** — Added `GET /auth/status` for the frontend to detect whether a session is active without triggering a login redirect.
- **Minitest to RSpec migration** — Replaced Minitest with RSpec, FactoryBot, and Shoulda Matchers. Added model and controller specs.
- **CLAUDE.md and .claudeignore** — Added AI assistant context files for the project.

## Known Issues

- **CI runs Minitest, not RSpec** — The GitHub Actions workflow still runs `bin/rails test test:system` instead of `bundle exec rspec`. Tests pass locally with RSpec but CI is running the wrong test framework.
- **CI installs sqlite3** — The `test` job in `ci.yml` runs `apt-get install sqlite3`, which is unnecessary since the project uses PostgreSQL. No PostgreSQL service is configured in CI either.
- **Inconsistent JSON rendering** — Catalog controllers use inline `as_json(only: [...]).merge(...)`. Lookup controllers mix between `render json: @model` (full serialization) and `render :show` (jbuilder views). No serializer layer.
- **No pagination** — All list endpoints return every record. Will become a problem as the catalog grows.
- **No backend filtering/search** — Index endpoints return all records; filtering happens client-side only.
- **Genre/tag sync duplication** — The `update_*_genres` and `update_*_tags` methods are copy-pasted across ArtistsController, AlbumsController, and TracksController with only model name differences.
- **Dockerfile references sqlite3** — The production Dockerfile (if present) may install sqlite3, a leftover from the Rails scaffold before PostgreSQL migration.
- **database.yml has stale SQLite comments** — The config file still contains commented-out SQLite configuration blocks.

## Open Questions

- **Lookup table access control** — Genre, Tag, Priority, Phase, Medium, Edition, and ReleaseType controllers have no authorization checks beyond `require_login`. Any authenticated user can create/delete lookup records that affect everyone. Should these be admin-only?
- **HTML view removal** — Controllers still have `respond_to` blocks with `format.html` handlers and there are presumably view templates. If the frontend is the primary UI, should the HTML views be removed to simplify the controllers?
- **Artist, Album and Track deletion by Users** - It is likely that those classes will need need to be edited or deleted over time, perhaps only be an admin level user?
- **Create of Admin priveleges** - There are probably many reasons this will be needed.
