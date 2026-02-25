# Mixtape

A multi-user music catalog and collection manager built with Rails.

Mixtape lets users browse a shared catalog of artists, albums, and tracks while maintaining personal preferences — ratings, genres, tags, listening status, and playlists — scoped to their own account. Authentication is handled via AWS Cognito through OmniAuth. A separate frontend application consumes the JSON API.

## Tech Stack

- Ruby 3.4 / Rails 7.2
- PostgreSQL
- AWS Cognito (OAuth 2.0 via OmniAuth)
- RSpec, FactoryBot, Shoulda Matchers
- Docker (production Dockerfile included)
- GitHub Actions CI (Brakeman, RuboCop, RSpec)

## Features

- **Shared catalog** — Artists, albums, and tracks exist once and are available to all users
- **Per-user preferences** — Each user has their own ratings (1-5), listened/explored flags, genre assignments, and tags for artists, albums, and tracks
- **Playlists** — User-scoped playlists with associated artists, tracks, tags, genre, and platform
- **Lookup tables** — Genres, tags, priorities, phases, media formats, editions, and release types
- **Authentication** — AWS Cognito login with session-based auth and a `/auth/status` endpoint for frontend session detection

## Architecture

Catalog records (Artist, Album, Track) are shared across all users. User-specific data lives in join models (UserArtist, UserAlbum, UserTrack) that hold ratings, tags, and genres scoped per user. This avoids data duplication while giving each user a personalized view of the catalog.

Controllers respond to both HTML and JSON formats. The JSON responses are consumed by a separate frontend application.

## Getting Started

### Prerequisites

- Ruby 3.4.2
- PostgreSQL
- Bundler

### Setup

```sh
git clone <repo-url>
cd mixtape
bundle install
```

### Environment Variables

Create a `.env` file in the project root with your AWS Cognito credentials:

```
COGNITO_CLIENT_ID=your_client_id
COGNITO_CLIENT_SECRET=your_client_secret
COGNITO_USER_POOL_ID=your_pool_id
COGNITO_DOMAIN=your_domain
COGNITO_REDIRECT_URI=http://localhost:3000/auth/cognito/callback
```

### Database

```sh
bin/rails db:create db:migrate
```

### Run the Server

```sh
bin/rails server
```

The app runs on `http://localhost:3000` by default.

## API Endpoints

All resource endpoints support standard CRUD operations and respond to JSON when requested with the appropriate `Accept` header.

| Resource         | Endpoint           | Description                          |
|------------------|--------------------|--------------------------------------|
| Artists          | `/artists`         | Music artists (shared catalog)       |
| Albums           | `/albums`          | Albums with artist, medium, edition  |
| Tracks           | `/tracks`          | Tracks linked to artist and album    |
| Playlists        | `/playlists`       | User-scoped playlists                |
| Genres           | `/genres`          | Genre lookup table                   |
| Tags             | `/tags`            | Tag lookup table                     |
| Priorities       | `/priorities`      | Priority levels for artists          |
| Phases           | `/phases`          | Listening phases for artists         |
| Media            | `/media`           | Media format lookup (vinyl, CD, etc.)|
| Editions         | `/editions`        | Edition lookup (deluxe, remaster)    |
| Release Types    | `/release_types`   | Release type lookup (LP, EP, single) |
| Auth Status      | `/auth/status`     | Current session/authentication check |

## Testing

The test suite uses RSpec with FactoryBot and Shoulda Matchers.

```sh
bundle exec rspec
```

## CI/CD

GitHub Actions runs on every push to `main` and on pull requests:

- **Brakeman** — Static analysis for security vulnerabilities
- **RuboCop** — Code style linting
- **Importmap audit** — JavaScript dependency security scan
- **RSpec** — Test suite
