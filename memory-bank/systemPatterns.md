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
- Index actions return records in alphabetical order with article prefix stripping (`/^(The|A|An)\s+/i` removed from artist names for sort purposes):
  - **Artists:** Ruby-level `.sort_by` with article stripping (e.g., "The Beatles" sorts under B)
  - **Albums:** Ruby-level `.sort_by` on `[artist name, album title]` after eager-loading (HABTM artist relationship makes SQL aggregation complex). VA albums use "various artists" as sort key. Unsorted album tracks (no position/disc_number) sort after positioned tracks, alphabetically by title.
  - **Tracks:** Ruby-level `.sort_by` on `[artist name, album title, track title]` after eager-loading (same HABTM reasoning)

Canonical example: `app/controllers/artists_controller.rb`

### 2. Lookup Controllers (Genres, Tags, Editions, Media, Phases, Priorities, ReleaseTypes)

Simple CRUD for reference data:
- Use `skip_before_action :verify_authenticity_token`
- No `UserPreferable` concern
- No transactions needed
- Delete destroys the actual record
- Index action returns in default database order (no explicit ordering) for Editions, Phases, Priorities, and Release Types. Genres and Media retain `.order(:name)` for alphabetical display.
- Index/show render JSON directly (no `respond_to` block in some cases)

Canonical example: `app/controllers/genres_controller.rb`

All controllers now render JSON directly (no `respond_to` blocks or HTML views).

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

    # 3. Assign preference-specific params and SAVE FIRST
    @user_pref.assign_attributes(preference_params)
    @user_pref.save!

    # 4. Sync genres and tags (these call pref.reload internally)
    update_artist_genres(@user_pref)
    update_artist_tags(@user_pref)

    # 5. Respond with merged JSON
    render json: { data: artist_json(@artist, @user_pref) }, status: :ok
  end
end
```

Note: `ArtistsController#create` uses `find_or_initialize_by(name:)` to avoid duplicate catalog records. `AlbumsController` and `TracksController` use `new` instead — albums/tracks are not deduplicated by title. `TracksController` additionally calls `handle_album_association` after save to create/update `AlbumTrack` join records when `album_id` is provided.

## Inline Track Creation Pattern (AlbumsController)

When `params[:album][:album_tracks]` is present, `handle_album_tracks` orchestrates a full sync of the album's tracklist within the same transaction as the album save:

1. **Split submitted entries** — Entries with `track_id` are existing tracks; entries with `title` (no `track_id`) are new inline tracks
2. **Remove deleted album_tracks** — Any `AlbumTrack` not in the submitted existing list is destroyed
3. **Sync existing entries** — `find_or_initialize_by(track_id, edition_id)` then update position/disc_number
4. **Create new inline tracks** — Each new entry calls `create_inline_track`:
   - `resolve_duplicate_title(title, existing_titles)` — appends `(n)` suffix for same-title tracks on the same album
   - Creates `Track` record with title, duration, isrc, `medium_id` (inherited from album)
   - **Artist assignment:** uses per-track `artist_ids` if provided (VA albums), otherwise inherits from album's `artist_ids`
   - Creates `UserTrack` preference for current user (with optional listened/rating)
   - **Genre assignment:** if per-track `genre_ids` are provided, creates `UserTrackGenre` records from those IDs; otherwise falls back to `copy_album_genres_to_track(user_track)` which copies the album's user genres (one-time copy, no ongoing propagation)
   - Creates `AlbumTrack` with position, disc_number, edition_id

This runs inside the same `ActiveRecord::Base.transaction` as the album create/update, so all tracks are committed atomically.

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
- **Reload:** Refreshes the in-memory association cache after modifying sub-joins
- **IMPORTANT:** `pref.reload` discards any unsaved attribute changes. Preference attributes (rating, complete, listened, priority_id, phase_id) must be saved via `save!` BEFORE calling genre/tag sync. This is fixed in all three catalog controllers (Artists, Albums, Tracks).
- This logic is duplicated across three controllers — not yet extracted to a shared module

## JSON Response Shape

Catalog controllers build JSON inline using `as_json` with merged preference fields. Index endpoints are scoped to the current user's collection via `joins` + `where`:

```ruby
# Index — scope to user's collection, pre-load preferences into a hash for O(1) lookup
@artists = Artist.joins(:user_artists).where(user_artists: { user_id: current_user.id })
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

All three catalog controllers extract this into private `*_json` helpers that include ID fields needed by the frontend form:
- `artist_json(artist, pref)` — includes `priority_id`, `phase_id`, `genre_ids`, `tag_ids`, `tag_name`
- `album_json(album, pref, user_track_prefs)` — includes `artist_ids`, `medium_id`, `release_type_id`, `consider_editions`, `default_edition_id`, `genre_ids`, `tag_ids`, `genre_name`, `tag_name`, and an `album_tracks` array (see below)
- `track_json(track, pref)` — includes `artist_ids` (array), `album_ids` (array), `medium_id`, `genre_ids`, `tag_ids`, `genre_name`, `tag_name`

The `album_json` response includes an `album_tracks` array sorted by `[disc_number, position]`. Each entry contains:
- `track_id`, `track_title`, `artist_name` (array), `artist_ids` (array)
- `position`, `disc_number`, `duration`, `isrc`
- `edition_id`, `edition_name`
- `listened` (boolean), `rating` (integer, from user_track preference)
- `genre_ids` (array), `genre_name` (array), `tag_ids` (array), `tag_name` (array) — from user_track preference, eager-loaded via `.includes(:genres, :tags)`

Lookup controllers use `render json: { data: @model }` with the `{ data: ... }` envelope.

## ExtJsFilterable Concern

Located at `app/controllers/concerns/ext_js_filterable.rb`. Provides `apply_ext_filters(scope)` for server-side filtering on index actions. Controllers define two constants:

**`FILTER_CONFIG`** — Hash mapping Ext JS `property` names to filter configurations:
```ruby
FILTER_CONFIG = {
  name:          { kind: :string,  column: "artists.name" },
  rating:        { kind: :number,  column: "user_artists.rating" },
  complete:      { kind: :boolean, column: "user_artists.complete" },
  priority_name: { kind: :list, model: Priority, column: "user_artists.priority_id" },
  artist_name:   { kind: :habtm_string, join_table: "albums_artists", join_fk: "album_id",
                   base_key: "albums.id", assoc_table: "artists", assoc_fk: "artist_id", assoc_column: "name" },
  genre_name:    { kind: :habtm_list, join_table: "user_artist_genres", join_fk: "artist_id",
                   base_key: "artists.id", user_scope: "user_artist_genres.user_id = user_artists.user_id",
                   assoc_table: "genres", assoc_fk: "genre_id", assoc_column: "name" }
}.freeze
```

**`SEARCH_FIELDS`** — Hash with `:joins` (LEFT JOIN SQL for associated tables with aliased names) and `:fields` (array of columns to OR-match with ILIKE).

Key design decisions:
- **Column filters use EXISTS subqueries** — no duplicate rows from HABTM joins
- **Text search uses LEFT JOINs** with aliased table names (`search_*`) to avoid conflicts with column filters
- **`.distinct` applied in controllers** after `apply_ext_filters` to eliminate any duplicates from text search JOINs
- **List filters receive names, not IDs** — the concern looks up IDs via the model
- **Genre filters are user-scoped** — EXISTS subquery includes `user_id` condition matching the outer user join

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
  - **Artist delete cascades:** Removing a `UserArtist` also removes the user's `UserAlbum` and `UserTrack` records for that artist's albums and tracks (via `@artist.album_ids` / `@artist.track_ids`). Uses `destroy_all` within a transaction so dependent callbacks fire on sub-join models (user_album_genres, user_album_tags, user_track_genres, user_track_tags). Does not affect other users' records or catalog records.
  - **Album and Track deletes do NOT cascade.** Deleting an album does not remove the user's track preferences, and vice versa.

- **Lookup/Playlist controllers**: Delete destroys the actual record.
  ```ruby
  @genre.destroy!
  @playlist.destroy!
  ```

**Planned:** Admin-level users will be able to delete actual catalog records (artists, albums, tracks), not just user preferences. This will require an admin role and authorization checks.

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

TracksController additionally handles album association outside strong params:
```ruby
def track_params
  params.require(:track).permit(:title, :duration, :isrc, :medium_id, artist_ids: [])
end
```
Album linking has two methods:
- `handle_album_association` — processes singular `album_id` (with `position`, `disc_number`) from Album Detail saves. Creates/updates a single `AlbumTrack` record.
- `handle_album_ids_association` — processes `album_ids` array from Track Detail saves. Syncs the full set of album associations: removes albums no longer in the list (via `destroy_all`), adds new ones as unsorted entries (no position, disc_number, or edition_id), reloads the track. Guard clause skips when `album_ids` key is absent.

## Ext.js Frontend CRUD Pattern

Artist is the template entity. Each entity needs 3 new files + modifications to 3 existing files.

### Three-File Pattern (new files per entity)

**1. `{Entity}View.js`** — Border layout container (`Ext.panel.Panel`)
- `layout: 'border'` with grid as `region: 'center'` and detail form as `region: 'east'`
- Detail panel: `collapsed: true`, `collapsible: true`, `split: true`, `width: 400`
- Attaches the entity's ViewController and an inline `viewModel` with `phantom: false` flag
- Grid wired to `cellclick: 'onGridCellClick'` (NOT `select` — see star rating note below)

**2. `{Entity}Detail.js`** — Form panel (`Ext.form.Panel`)
- Requires `mixtape.view.common.StarRating` for the rating field
- Fields for catalog data (textfields) and preference data (starrating, checkbox, comboboxes, tagfields)
- Comboboxes use `queryMode: 'local'` with lookup stores (`{ type: 'priorities' }`, etc.)
- Artist and track tagfields/comboboxes use `anyMatch: true` so users can type any part of a name to find a match (e.g., "Smashing" finds "The Smashing Pumpkins")
- Save button with `formBind: true` and Cancel button

**3. `{Entity}Controller.js`** — ViewController (`Ext.app.ViewController`)
- `onGridCellClick(view, td, cellIndex, record, tr, rowIndex, e)`:
  - First arg is the grid **view** (not the grid panel) — use `view.getHeaderCt().getGridColumns()[cellIndex]` to get the column
  - If rating column and click target is a `.star-rating-star` span: send inline `PUT` with just `{ entity: { rating: N } }`, update record locally via `record.set()` + `record.commit()`, then `return` (don't open detail panel)
  - Otherwise: load record into detail form, expand detail panel
  - **After `loadRecord`:** Explicitly call `setValue` on custom/array fields (StarRating, tagfields) — `loadRecord` does not reliably set them. Set `phantom: false` LAST, after all `setValue` calls, to prevent `change` listeners from running with stale phantom state
- `onSaveClick`: Build payload by reading each field's `getValue()` directly (do NOT use `form.getValues()` — it misses custom fields like StarRating and tagfields that lack native `<input>` elements)
- `onAddClick`: Reset form, expand detail, deselect grid, set `phantom: true`
- `onDeleteClick`: Confirm dialog, send `DELETE`, reload store
- All AJAX requests use `withCredentials: true` for session cookies

### Star Rating Widget

Reusable component at `app/view/common/StarRating.js`:
- Extends `Ext.form.field.Base`, alias `widget.starrating`
- Uses FontAwesome 5 classes: `fas fa-star` (gold filled, color `#f5a623`) and `far fa-star` (gray outline, color `#ccc`)
  - **NOT** FA4's `fa-star-o` — that class doesn't exist in the bundled FA5
- Each star is a `<span>` with `display:inline-block` and fixed width for consistent click targets (empty outline stars are tiny without this)
- Grid renderer: 14px stars, 16px wide spans; Form field: 18px stars, 20px wide spans
- Click a star to set rating; clicking the current rating keeps it (no toggle-to-clear)
- Implements `setValue`, `getValue`, `setRawValue`, `getRawValue` for form integration
- Works with `form.loadRecord()` and `form.reset()`
- **Requires explicit `setValue` after `loadRecord`** — `form.loadRecord()` does not reliably set values on custom `Ext.form.field.Base` subclasses (same issue as tagfields with array values). After `loadRecord`, call `ratingField.setValue(record.get('rating'))` explicitly

### DurationField Widget

Reusable component at `app/view/common/DurationField.js`:
- Custom text field that parses "m:ss" input to seconds and displays seconds as "m:ss"
- Used in the Album Detail tracklist grid and Track Detail form
- Handles conversion bidirectionally: user types "3:45" → stored as 225 seconds; display converts 225 → "3:45"

### Album Detail Tracklist Grid

The Album Detail form includes an inline tracklist grid for viewing and editing album tracks:
- **CellEditing plugin** — enables inline editing of track fields (title, duration, ISRC, per-track artists for VA)
- **Entry mode toggle** — "Enter Track Names" checkbox switches the grid into entry mode. New rows are added with `is_new: true` flag and are not saved until the album form is submitted
- **Typeahead combobox** — Track title column uses a combobox with `displayField: 'title_with_artist'` and local store sorter for alphabetical ordering. Artist filtering applied in `onBeforeEdit` for non-VA albums (same filter logic as Add Track modal)
- **Add Track modal** — `openAddTrackModal` in `AlbumController.js` creates a modal with a track combobox using `displayField: 'title_with_artist'`, local alphabetical sorter, and artist filtering for non-VA albums (reads VA checkbox and `artist_ids` from album form, applies `filterBy` on combo store in `afterrender` listener). VA albums show all tracks unfiltered.
- **`title_with_artist` computed field** — `persist: false` field on Track model (`app/model/Track.js`) that formats as `"Title – Artist1, Artist2"`. Used as `displayField` on all track-selection comboboxes to disambiguate same-title tracks by different artists.
- **Edition filter combobox** — Dropdown to filter tracklist by edition; visibility controlled by `consider_editions` checkbox
- **Edition column** — Shows edition name per track; visibility also tied to `consider_editions`
- **Per-track artist editing** — For VA albums (`various_artists: true`), each track row has an editable artist field; for non-VA albums, artists are inherited from the album
- **ISRC, Listened, Rating, Genres columns** — Visible by default. Editable only on `is_new` rows in entry mode (except Listened/Rating which are editable on all rows in entry mode). Genre column uses tagfield editor with genres store; pre-populated from album genres for non-VA albums, empty for VA albums. Genre IDs included in save payload; backend uses them to create `UserTrackGenre` records (or falls back to copying album genres if absent)
- **Edition column** — Hidden by default; visibility toggled by `updateEditionVisibility` based on `consider_editions`
- **Tracklist data fetched from show endpoint** — `onGridCellClick` makes a `GET /albums/:id` request to populate the tracklist with full user track preferences (listened, rating, genres, tags). The index endpoint passes `{}` for user_track_prefs to keep it lightweight, so track-level user data is only loaded on detail view. Fresh `album_tracks` are written back to the grid record for use by `onConsiderEditionsChange` and other handlers

### VA Album Pattern

- "VA Collection" checkbox on the album form sets `various_artists: true` on the catalog record
- When checked: artist tagfield is disabled/cleared (album has no single artist), per-track `artist_ids` are sent for inline-created tracks
- When unchecked: album's `artist_ids` are inherited by all new inline tracks
- In JSON output, `artist_name` returns `['Various Artists']` when `various_artists` is true

### Edition UI Pattern

- "Consider Editions" checkbox on the album form toggles `consider_editions` on the UserAlbum preference
- When checked: edition filter dropdown, edition column, "Manage Editions" button, and "Default Edition" checkbox become visible in the tracklist grid
- When unchecked: edition UI is hidden, all tracks shown regardless of edition
- Edition is stored on `AlbumTrack` (not Album), so the same track can appear on different editions
- **Default Edition:** Users can set a default edition per album via `default_edition_id` on `UserAlbum`. When loading an album with a default edition, the edition filter auto-selects it. The "Default Edition" checkbox in the tracklist tbar saves/clears this preference via PUT. A `_syncingDefaultEdition` guard flag prevents the checkbox change handler from re-saving when the checkbox is being programmatically synced (e.g., on album load or edition filter change)

### Existing File Modifications (per entity)

- **Grid**: Add `tbar` with Add/Delete buttons. Add star `renderer` on rating column (width: 110)
- **Model**: Add ID fields (`priority_id`, `phase_id`, `genre_ids`, `tag_ids`, `tag_name`) for form population
- **Main.js**: Swap grid xtype for view xtype in navigation

### Genre Auto-Populate from Artists (Albums)

When adding a new album, selecting artists auto-populates the genre tagfield with the union of those artists' genres. Implemented via a `change` listener on the `artist_ids` tagfield that routes to `onArtistChange` in `AlbumController.js`:

- **New albums only** (`phantom === true`): replaces genre field with merged artist genres (deduplicated via `Ext.Array.unique`)
- **Existing albums** (`phantom === false`): returns early, no auto-population
- Artist records in the Artists store include `genre_ids` (populated by the backend's `artist_json` helper), so no extra API calls needed
- User can freely modify genres after auto-population

### Main.js Navigation

The center panel in `Main.js` should NOT have a `reference` config. The `removeAll()` / `add()` navigation pattern triggers Ext JS's asynchronous `fixReferences` cleanup, which produces `[W] Duplicate reference` warnings if the container has a `reference` set. The navigation handler locates the center panel via `view.up('viewport').down('panel[region=center]')` instead.

### Backend Requirements (per entity)

- Controller must include ID fields in JSON responses (see `artist_json`/`album_json`/`track_json` helper pattern)
- Controller `update` must call `save!` BEFORE genre/tag sync to prevent `pref.reload` data loss (all three catalog controllers now follow this pattern)

## Testing Patterns

### RSpec Controller Spec Pattern

```ruby
RSpec.describe SomeController, type: :controller do
  let(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns records with user preferences' do
      record = create(:some_model)
      create(:user_some_model, user: user, some_model: record, rating: 5)

      get :index, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json.first['rating']).to eq(5)
    end
  end
end
```

Key conventions: `sign_in(user)` helper, `as: :json` format, parse from `['data']`, create join records explicitly for user preferences, test auth rejection separately.

### RSpec Model Spec Pattern

```ruby
RSpec.describe SomeModel, type: :model do
  it 'has a valid factory' do
    expect(build(:some_model)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:users).through(:user_some_models) }
    it { is_expected.to belong_to(:lookup).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
```

Key conventions: factory validation first, Shoulda Matchers for associations/validations, `.optional`/`.dependent(:destroy)` modifiers.

### Playwright E2E Test Pattern

```javascript
const { waitForExtReady, navigateToView } = require('./helpers/extjs');

test.beforeEach(async ({ page }) => {
  await page.goto('/');
  await waitForExtReady(page);
  await navigateToView(page, 'Albums');
});
```

Key conventions: wait for `Ext.isReady` via shared helper, navigate via tree nodes using `navigateToView()`, wait for grid via `getByRole('grid')`, use Ext.js CSS selectors (`.x-grid-row`, `.x-column-header-text`, `.x-form-item`, `.x-btn-inner`). Shared helpers in `e2e/helpers/extjs.js`.

### Claude Code Test Sub-Agent Architecture

Two specialized agents in separate repos, each with 3 slash commands (write/run/debug). Backend agent knows RSpec/FactoryBot/Shoulda. Frontend agent knows Playwright/Ext.js/MCP tools. Each agent references its repo's test patterns as templates.
