# System Patterns

## Controller Taxonomy

The application has four distinct controller types, each with different responsibilities:

### 1. Catalog Controllers (Artists, Albums, Tracks)

These manage shared catalog records and per-user preferences together. All three:
- Include `UserPreferable` concern
- Use `skip_before_action :verify_authenticity_token`
- Wrap create/update in `ActiveRecord::Base.transaction`
- Split params into catalog params and preference params
- Sync genres and tags via private helper methods
- Delete only the user preference on destroy, not the catalog record

Canonical example: `app/controllers/artists_controller.rb`

### 2. Lookup Controllers (Genres, Tags, Editions, Media, Phases, Priorities, ReleaseTypes)

Simple CRUD for reference data:
- Use `skip_before_action :verify_authenticity_token`
- No `UserPreferable` concern
- No transactions needed
- Delete destroys the actual record
- Index/show render JSON directly (no `respond_to` block in some cases)

Canonical example: `app/controllers/genres_controller.rb`

### 3. PlaylistsController

User-scoped CRUD:
- Uses `skip_before_action :verify_authenticity_token`
- All queries scoped through `current_user.playlists`
- `set_playlist` finds within `current_user.playlists` (enforces ownership)
- Create builds via `current_user.playlists.build`
- Destroy deletes the actual playlist record
- No `UserPreferable` concern (playlists are inherently user-scoped)

### 4. SessionsController

Authentication handling:
- Skips `require_login` on callback and status endpoints
- Skips forgery protection on OAuth callback actions
- `create`/`oidc_callback` both delegate to `handle_omniauth_auth!`
- `status` endpoint returns current auth state as JSON
- `destroy` clears session and redirects to Cognito logout URL

## Transaction-Based Create/Update Pattern

Catalog controllers (Artists, Albums, Tracks) follow this sequence inside a transaction:

```ruby
ActiveRecord::Base.transaction do
  # 1. Save the catalog record
  @artist = Artist.find_or_initialize_by(name: artist_params[:name])  # or Album.new / Track.new
  @artist.assign_attributes(artist_params)

  if @artist.save
    # 2. Find or initialize the user preference
    @user_pref = current_user_artist(@artist)   # from UserPreferable concern

    # 3. Assign preference-specific params
    @user_pref.assign_attributes(preference_params)

    # 4. Sync genres and tags
    update_artist_genres(@user_pref)
    update_artist_tags(@user_pref)

    # 5. Save the preference
    @user_pref.save!

    # 6. Respond with merged JSON
    respond_to { ... }
  end
end
```

Note: `ArtistsController#create` uses `find_or_initialize_by(name:)` to avoid duplicate catalog records. `AlbumsController` and `TracksController` use `new` instead — albums/tracks are not deduplicated by title.

## Genre/Tag Sync Pattern

Each catalog controller has private methods to sync genres and tags. The pattern is identical across all three controllers (artists, albums, tracks):

```ruby
def update_artist_genres(pref)
  return unless params[:artist].key?(:genre_ids)

  genre_ids = Array(params[:artist][:genre_ids]).map(&:to_i)
  pref.save! if pref.new_record?     # must persist before creating sub-joins
  pref.user_artist_genres.where.not(genre_id: genre_ids).destroy_all   # remove deselected
  genre_ids.each do |gid|
    pref.user_artist_genres.find_or_create_by!(user: current_user, artist: pref.artist, genre_id: gid)
  end
  pref.reload
end
```

Key details:
- **Guard clause:** Only runs if the param key is present (allows partial updates)
- **Save-if-new:** Sub-joins require the preference record to be persisted first
- **Destroy missing:** Removes any genres/tags no longer in the submitted list
- **Find or create remaining:** Idempotent — won't duplicate existing associations
- **Reload:** Refreshes the in-memory association cache
- This logic is duplicated across three controllers — not yet extracted to a shared module

## JSON Response Shape

Catalog controllers build JSON inline using `as_json` with merged preference fields:

```ruby
# Index — pre-load preferences into a hash for O(1) lookup
@user_prefs = current_user.user_artists.includes(:priority, :phase, :genres, :tags).index_by(&:artist_id)

render json: @artists.map { |artist|
  pref = @user_prefs[artist.id]
  artist.as_json(only: [:id, :name, :wikipedia, :discogs]).merge(
    complete: pref&.complete || false,
    rating: pref&.rating,
    genre_name: pref&.genre_name || [],
    priority_name: pref&.priority_name,
    phase_name: pref&.phase_name
  )
}
```

The `as_json(only: [...])` pattern whitelists catalog fields, then `.merge(...)` appends preference fields. Albums and tracks use `methods: [...]` to include computed fields like `artist_name` and `medium_name`.

Lookup controllers render differently — some use `render json: @genres` (full serialization), others use `render :show` (jbuilder views).

## UserPreferable Concern

Located at `app/controllers/concerns/user_preferable.rb`. Provides three helper methods:

```ruby
def current_user_artist(artist)
  current_user.user_artists.find_or_initialize_by(artist: artist)
end

def current_user_album(album)
  current_user.user_albums.find_or_initialize_by(album: album)
end

def current_user_track(track)
  current_user.user_tracks.find_or_initialize_by(track: track)
end
```

`find_or_initialize_by` returns the existing preference if one exists, or an unsaved new one if not. This means show/edit always work even if the user hasn't set preferences yet.

## Delete Semantics

Two different behaviors depending on controller type:

- **Catalog controllers** (Artists, Albums, Tracks): Delete only removes the current user's preference record. The catalog record itself is preserved for other users.
  ```ruby
  current_user.user_artists.where(artist: @artist).destroy_all
  ```

- **Lookup/Playlist controllers**: Delete destroys the actual record.
  ```ruby
  @genre.destroy!
  @playlist.destroy!
  ```

## Authentication Pattern

Defined in `ApplicationController`:

```ruby
before_action :set_current_user
before_action :require_login

def current_user
  @current_user ||= User.find_by(id: session[:user_id])
end

def require_login
  head :unauthorized unless current_user
end
```

- `require_login` runs globally on all controllers
- `SessionsController` selectively skips it: `skip_before_action :require_login, only: [:create, :oidc_callback, :destroy, :passthru, :status]`
- `Current.user` is set via `set_current_user` for access outside controllers

## Strong Parameters Split

Catalog controllers extract two separate param sets from the same top-level key:

```ruby
# Catalog fields
def artist_params
  params.require(:artist).permit(:name, :wikipedia, :discogs)
end

# Preference fields
def preference_params
  params.require(:artist).permit(:rating, :complete, :priority_id, :phase_id)
end
```

Genre/tag IDs are extracted directly from `params[:artist][:genre_ids]` outside of strong params, since they're processed by the sync methods rather than `assign_attributes`.
