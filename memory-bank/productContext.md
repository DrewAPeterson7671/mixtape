# Product Context

## Why This Project Exists

Mixtape solves a personal problem: tracking a large music collection across artists, albums, and tracks with subjective metadata that varies per listener. Commercial services (Spotify, Last.fm, RateYourMusic) couple catalog data with their own platforms. Mixtape separates the catalog from any streaming service, letting users maintain a standalone record of what they've listened to, how they rate it, and how they categorize it.

## Who Uses It

Single-user in practice (the developer), but architected for multi-user from the start. The shared catalog / per-user preference split means multiple users could share the same artist/album/track records while each maintaining independent ratings, genres, tags, and listening status.

## What Users Do

### Core Workflows

1. **Browse the catalog** — View lists of artists, albums, and tracks. Each list merges shared catalog data with the current user's preference data (ratings, genres, completion status).

2. **Add to the catalog** — Create new artist, album, or track records. On creation, a user preference record is also initialized so the user can immediately set ratings, genres, and tags.

3. **Annotate with preferences** — For any catalog record, a user can:
   - Rate it (1-5 scale, optional)
   - Assign genres (multiple, from a shared genre list)
   - Assign tags (multiple, from a shared tag list)
   - Mark listening/completion status (`listened` for albums/tracks, `complete` for artists)
   - Set priority and phase (artists only)

4. **Manage playlists** — Create user-scoped playlists that reference artists, tracks, and tags. Playlists have their own metadata: name, platform, genre, year, source, comment, sequence.

5. **Manage lookup data** — Create and edit the shared reference tables (genres, tags, priorities, phases, media, editions, release types) that populate dropdowns and categorization options.

### What "Delete" Means

Deleting an artist, album, or track from the UI removes only the user's preference record — the catalog record stays for other users. Deleting a playlist or lookup record removes it entirely.

## How It Differs From Alternatives

| Concern | Mixtape | Streaming Services | RateYourMusic/Discogs |
|---------|---------|-------------------|----------------------|
| Catalog ownership | Self-hosted, user-controlled | Platform-locked | Platform-hosted |
| Metadata freedom | Unlimited genres, tags per user | Platform categories | Community-driven |
| Per-user isolation | Each user has independent preferences | Single account | Single account |
| Audio playback | None — metadata only | Core feature | Limited |
| Data portability | Direct database access | API-dependent | Export tools |

## Product Boundaries

- **No audio playback or storage** — This is a catalog/metadata tool, not a player.
- **No social features** — No sharing, following, or public profiles.
- **No import/sync** — No integration with Spotify, Apple Music, or other services (yet).
- **No mobile app** — Web-only via the separate frontend.
- **No search or filtering on the backend** — The frontend handles filtering client-side over full dataset loads.
