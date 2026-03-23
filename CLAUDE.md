# CLAUDE.md

Rails JSON API backend for a music catalog app. The frontend is a separate project at `/Users/drewpeterson/code/pers/music-project/mixtapeUI/mixtape`.

## Memory Bank

For detailed documentation, see the `memory-bank/` directory.

The Memory Bank files are a living document that summarizes this project and it's many aspects.  It is a knowledge base for both the frontend and backend apps.

Review it when planning for this app.

Upon a commit, please update the memory bank with an relevant changes.

## Architecture

Catalog records (Artist, Album, Track) are shared across all users. User-specific data (ratings, tags, genres, listened/explored flags) lives in join models: UserArtist, UserAlbum, UserTrack. Never put user-specific fields on the catalog models directly.

## Ruby Environment

Ruby 3.4.2 is managed via rbenv. The CLI agent's shell may not resolve rbenv correctly — if `bin/rails` or `bundle exec` fail with "version not installed", have the user run commands directly in their terminal.

## Common Commands

- `bundle exec rspec` — run tests
- `bin/rails server` — start dev server (port 3000)
- `bin/rails db:migrate` — run pending migrations
- `bin/brakeman --no-pager` — security scan (runs in CI)
- `bin/rubocop` — lint (runs in CI)
- `POST /test/login` — dev/test-only endpoint for E2E auth bypass (sets session directly, accepts `email` and `name` params)

## Slash Commands (Test Sub-Agent)

Custom Claude Code commands in `.claude/commands/` for RSpec testing:

- `/project:test-write <model or controller>` — Generates a new RSpec spec following existing patterns (FactoryBot, Shoulda Matchers, `sign_in` helper)
- `/project:test-run [path]` — Runs `bundle exec rspec` (full suite or targeted), analyzes failures
- `/project:test-debug <failure>` — Diagnoses a specific test failure by reading spec + source + factories
- `/project:test-full <model or controller>` — Full cycle: writes spec, runs it, diagnoses/fixes failures, re-runs (up to 3 attempts)

## Dev Database

PostgreSQL runs on port **5433** (not the default 5432). Dev credentials are in `config/database.yml`.

## Authentication

AWS Cognito via OmniAuth with session-based auth. `current_user` is looked up from `session[:user_id]` in ApplicationController. `require_login` runs as a before_action on all controllers. Cognito credentials are loaded from `.env` via dotenv-rails (not Rails credentials).

## Code Patterns

- Controllers respond to both HTML and JSON via `respond_to do |format|`
- Controllers serving JSON to the frontend use `skip_before_action :verify_authenticity_token`
- The `UserPreferable` concern is included in controllers that manage per-user preferences
- Ratings are 1-5 integers, nullable
- Always scope user-specific data through `current_user`

## Testing

RSpec with FactoryBot and Shoulda Matchers. No Minitest.

## MCP Servers

Configured in `.mcp.json`. The `playwright` MCP server (`@playwright/mcp`) launches a headed browser that Claude Code can drive interactively — useful for debugging UI issues, testing flows, and navigating the app during dev sessions.
