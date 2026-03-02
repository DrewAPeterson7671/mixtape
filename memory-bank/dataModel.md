# Data Model

The data model has three tiers: shared catalog records, per-user preference join models, and per-user-per-record sub-join models for genres and tags.

## Model Tiers

```
Tier 1: Catalog Models (shared)        Artist, Album, Track
Tier 2: User Preference Models          UserArtist, UserAlbum, UserTrack
Tier 3: Sub-Join Models (per-user)      User{Artist,Album,Track}{Genre,Tag}
```

Lookup tables (Genre, Tag, Priority, Phase, Medium, Edition, ReleaseType) are shared reference data used across all tiers.

## Catalog Models

### Artist
- **Fields:** `name`, `wikipedia`, `discogs`
- **Validations:** `name` uniqueness
- **Relationships:** HABTM `albums`, HABTM `tracks` (via `artists_tracks`), HABTM `playlists`, has_many `user_artists` (dependent: destroy)

### Album
- **Fields:** `title`, `year`, `release_type_id`, `medium_id`, `edition_id`
- **Validations:** `title` presence; `year` integer 1500..current year (nullable)
- **Relationships:** HABTM `artists`, has_many `album_tracks` (dependent: destroy), has_many `tracks` through `album_tracks`, belongs_to `medium`/`edition`/`release_type` (all optional), has_many `user_albums` (dependent: destroy)
- **Helper methods:** `artist_name`, `release_type_name`, `medium_name`, `edition_name`

### Track
- **Fields:** `title`, `duration` (integer, seconds), `isrc` (string, indexed), `medium_id`
- **Validations:** `title` presence
- **Relationships:** HABTM `artists` (via `artists_tracks`), has_many `album_tracks` (dependent: destroy), has_many `albums` through `album_tracks`, belongs_to `medium` (optional), HABTM `playlists`, has_many `user_tracks` (dependent: destroy)
- **Helper methods:** `artist_name` (returns array), `album_title` (returns array), `medium_name`
- **Note:** Track represents a unique recording. Multiple artists supported via HABTM (matching Album pattern). Album association via `AlbumTrack` join model with position/disc metadata, so the same track can appear on multiple albums without duplication.

### AlbumTrack (join model)
- **Fields:** `album_id`, `track_id`, `position` (integer), `disc_number` (integer)
- **Validations:** `album_id` uniqueness scoped to `track_id`
- **Relationships:** belongs_to `album`, belongs_to `track`
- **Note:** This is a `has_many :through` model (not HABTM) because it carries `position` and `disc_number` metadata.

## User Preference Models

These join a `User` to a catalog record and hold per-user metadata.

### UserArtist
- **Fields:** `user_id`, `artist_id`, `rating`, `complete` (boolean, default false), `priority_id`, `phase_id`
- **Validations:** `artist_id` uniqueness scoped to `user_id`; `rating` integer 1-5 (nullable)
- **Relationships:** belongs_to `user`, `artist`, `priority` (optional), `phase` (optional); has_many `user_artist_genres`/`user_artist_tags` (scoped — see below)
- **Helper methods:** `genre_name`, `priority_name`, `phase_name`

### UserAlbum
- **Fields:** `user_id`, `album_id`, `rating`, `listened` (boolean, default false)
- **Validations:** `album_id` uniqueness scoped to `user_id`; `rating` integer 1-5 (nullable)
- **Relationships:** belongs_to `user`, `album`; has_many `user_album_genres`/`user_album_tags` (scoped)

### UserTrack
- **Fields:** `user_id`, `track_id`, `rating`, `listened` (boolean, default false)
- **Validations:** `track_id` uniqueness scoped to `user_id`; `rating` integer 1-5 (nullable)
- **Relationships:** belongs_to `user`, `track`; has_many `user_track_genres`/`user_track_tags` (scoped)
- **Helper methods:** `genre_name` (returns array of genre names)

## Scoped Sub-Join Pattern

Sub-join models (UserArtistGenre, UserArtistTag, UserAlbumGenre, etc.) associate a genre or tag with a specific user's preference for a specific catalog record. They use a **three-column composite key**: `(user_id, <catalog_id>, genre_id/tag_id)`.

The critical design detail: these sub-joins reference the **catalog record ID directly** (e.g., `artist_id`), not the user preference ID (`user_artist_id`). This means a standard `has_many` on UserArtist would return rows for all users, not just the current one.

The solution is a **scoped lambda** on the `has_many`:

```ruby
# In UserArtist:
has_many :user_artist_genres, ->(ua) { where(user_id: ua.user_id) },
         foreign_key: :artist_id, inverse_of: false, dependent: :destroy
has_many :genres, through: :user_artist_genres
```

This pattern is repeated identically across all six sub-join relationships (genres and tags for each of Artist, Album, Track).

### Sub-Join Model Structure

Each sub-join model (e.g., `UserArtistGenre`) follows the same pattern:
- **belongs_to:** `user`, `<catalog_model>`, `genre`/`tag`
- **Validates uniqueness** of the genre/tag scoped to `[user_id, <catalog_id>]`
- **Database index:** unique composite index on `(user_id, <catalog_id>, genre_id/tag_id)`

## Lookup Tables

Simple `name`-only models with no custom logic:

| Model | Used By |
|-------|---------|
| Genre | UserArtistGenre, UserAlbumGenre, UserTrackGenre, Playlist |
| Tag | UserArtistTag, UserAlbumTag, UserTrackTag, Playlist (HABTM) |
| Priority | UserArtist |
| Phase | UserArtist |
| Medium | Album, Track |
| Edition | Album |
| ReleaseType | Album |

## Playlist

- **Fields:** `sequence`, `name`, `platform`, `comment`, `genre_id`, `year`, `source`, `user_id`
- **Validations:** `name` presence + uniqueness scoped to `user_id`; `platform` presence; `year` integer 1500..current year (nullable)
- **Relationships:** belongs_to `genre`, belongs_to `user`; HABTM `artists`, `tracks`, `tags`
- **Scoping:** Playlists are always user-scoped — `current_user.playlists`

## User

- **Fields:** `email`, `name`, `cognito_sub` (unique, not null)
- **Relationships:** has_many `user_artists`, `user_albums`, `user_tracks`, `playlists` (all dependent: destroy)

## HABTM Join Tables

These are ID-less join tables with dual unique indexes:

| Table | Joins |
|-------|-------|
| `albums_artists` | Album <-> Artist |
| `artists_tracks` | Artist <-> Track |
| `artists_playlists` | Artist <-> Playlist |
| `playlists_tracks` | Playlist <-> Track |
| `playlists_tags` | Playlist <-> Tag |

Note: `album_tracks` is NOT a HABTM table — it's a full model (`AlbumTrack`) with its own `id`, `position`, `disc_number`, and timestamps, managed via `has_many :through`.

## Entity Relationship Overview

```
                        ┌─────────────┐
                        │    User     │
                        └──────┬──────┘
               ┌───────────────┼───────────────┐
               ▼               ▼               ▼
         ┌───────────┐  ┌───────────┐  ┌───────────┐
         │UserArtist │  │ UserAlbum │  │ UserTrack │
         └─────┬─────┘  └─────┬─────┘  └─────┬─────┘
          ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
          ▼         ▼    ▼         ▼    ▼         ▼
     UA_Genres  UA_Tags UA_Genres UA_Tags UT_Genres UT_Tags
          │         │    │         │    │         │
          ▼         ▼    ▼         ▼    ▼         ▼
        Genre      Tag  Genre     Tag  Genre     Tag
               │               │               │
               ▼               ▼               ▼
          ┌────────┐     ┌────────┐     ┌────────┐
          │ Artist │◄───►│ Album  │◄───►│ Track  │
          └────┬───┘HABTM└────────┘ HMT └────┬───┘
               │    HABTM                HABTM│
               ├─────────────────────────────►│
               │                              │
               │         ┌──────────┐         │
               └────────►│ Playlist │◄────────┘
                   HABTM └────┬─────┘ HABTM
                              │
                         Tags (HABTM)

  Album◄──►Track: via AlbumTrack join model (position, disc_number)
  Artist◄──►Track: via artists_tracks HABTM
  Lookup tables: Priority, Phase ──► UserArtist
                 Medium ──► Album, Track
                 Edition, ReleaseType ──► Album
                 Genre ──► Playlist
```
