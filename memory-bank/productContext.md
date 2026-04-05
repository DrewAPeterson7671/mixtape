# Product Context

## Why This Project Exists

Mixtape solves a personal problem: tracking a large music collection across artists, albums, and tracks with subjective metadata that varies per listener. Commercial services (Spotify, Last.fm, RateYourMusic) couple catalog data with their own platforms. Mixtape separates the catalog from any streaming service, letting users maintain a standalone record of what they've listened to, how they rate it, and how they categorize it. Mixtape will connect to Apple Music and Spotify to import preferences and populate the Mixtape database.  Users can then better curate what they listened to and in what directions they would like to explore further.  Users will be able to create smartplaylists to dynamically build open-ended playlists that will be exported to the streaming platforms.

## Who Uses It

Single-user in practice (the developer), but architected for multi-user from the start. The shared catalog / per-user preference split means multiple users could share the same artist/album/track records while each maintaining independent ratings, genres, tags, and listening status.

## What Users Do

Users will curate their music. They will be able to tailor dynamic playlists that can be exported to their streaming platforms.

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

6. **Import/Export CSV** - CSV will be used to import artists, tracks, albums, playlists, etc.  They will also be exportable.

7. **Smart Playlists** - Playlists can be created dynamically.  Such as creating a playlist of the 10 least recently played tracks of artists that start with the first letter "B" in the genre of "Reggae" that is from the phase "High School" and as the tracks are played, they are automatically removed from the list and replaced with the newest 'least recently played'.

8. **Searching and Filtering** - Extensive searching and filtering.  Split screens with drag and drop features.

9. **Streaming Platform Sync** - The application will reach out to the streaming platform to populate existing artist, albums, etc.  When playlists are generated, they will be exported back out to the streaming platforms for listening.

### What "Delete" Means

Deleting an artist, album, or track from the UI removes only the user's preference record — the catalog record stays for other users. Deleting a playlist or lookup record removes it entirely.  There will be an admin level user allowed to delete artists, albums and tracks.

## How It Differs From Alternatives

| Concern | Mixtape | Streaming Services | RateYourMusic/Discogs |
|---------|---------|-------------------|----------------------|
| Catalog ownership | Self-hosted, user-controlled | Platform-locked | Platform-hosted |
| Metadata freedom | Unlimited genres, tags per user | Platform categories | Community-driven |
| Per-user isolation | Each user has independent preferences | Single account | Single account |
| Audio playback | None — metadata only | Core feature | Limited |
| Data portability | Direct database access | API-dependent | Export tools |
| Smart playlists | Dynamic rule-based generation | Platform-specific | Not available |
| Streaming sync | Import catalog + export playlists | N/A (native) | Limited import |
| CSV import/export | Full catalog and playlist support | Not available | Export only |

## Product Boundaries

- **No audio playback or storage** — This is a catalog/metadata tool, not a player.
- **No social features** — No sharing, following, or public profiles.
- **No mobile app** — Web-only via the separate frontend.

