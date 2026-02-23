# CLAUDE.md

Rails JSON API backend for a music catalog app. The frontend is a separate project at `/Users/drewpeterson/code/pers/music-project/mixtapeUI/mixtape`.

## Architecture

Catalog records (Artist, Album, Track) are shared across all users. User-specific data (ratings, tags, genres, listened/explored flags) lives in join models: UserArtist, UserAlbum, UserTrack. Never put user-specific fields on the catalog models directly.

## Common Commands

- `bundle exec rspec` — run tests
- `bin/rails server` — start dev server (port 3000)
- `bin/brakeman --no-pager` — security scan (runs in CI)
- `bin/rubocop` — lint (runs in CI)

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
