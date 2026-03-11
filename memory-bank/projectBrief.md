# Project Brief

## Project Overview

Mixtape is a personal music catalog and collection manager. It lets users track artists, albums, and tracks they care about, annotating each with ratings, genres, tags, and listening status.

The architecture is split across two repositories:

- **Backend (this repo)** — A Rails 7.2 JSON API application. Runs on `localhost:3000`.
- **Frontend** — A separate JavaScript application located at `/Users/drewpeterson/code/pers/music-project/mixtapeUI/mixtape`. Runs on `localhost:1841` and communicates with the backend exclusively via JSON endpoints.

The backend is the system of record for all data. The frontend is a consumer of its API.

## Core Goals

- Maintain a **shared catalog** of artists, albums, and tracks that exists independent of any single user.
- Allow each user to layer **personalized metadata** on top of catalog records: ratings, genres, tags, listening/completion status, priority, and phase.
- Keep catalog data and user-specific data strictly separated at the model level — user preferences live in join models (`UserArtist`, `UserAlbum`, `UserTrack`), never on the catalog models themselves.
- Allow the creation of smart playlists that can dynamically build playlists from many combinations of attributes.
- Import and Export CSV files.
- Connect to streaming services to import data and export playlists.

## Scope Boundaries

- This repo is the **backend only**. Frontend changes happen in the separate mixtapeUI repository.
- There are **no background jobs** (no Sidekiq, no Active Job queues).
- The app does **not store or stream audio files**. It is purely a metadata catalog.
- **Authentication is delegated to AWS Cognito** via OmniAuth OIDC. The backend does not manage passwords or tokens directly — it receives an auth callback and stores a session cookie.
- There is currently **no pagination or server-side filtering** on list endpoints.

## Frontend Relationship

The frontend app at `localhost:1841` makes JSON requests to `localhost:3000`. Key integration details:

- **CORS** is configured to allow requests from `http://localhost:1841` (see `config/initializers/cors.rb`).
- **Session auth** carries across via a `_app_session` cookie with `SameSite=Lax` in development.
- **CSRF tokens are skipped** on controllers that serve JSON to the frontend (`skip_before_action :verify_authenticity_token`).
- The frontend checks login status via `GET /auth/status`, which returns `{ logged_in: true/false, user: {...} }`.
