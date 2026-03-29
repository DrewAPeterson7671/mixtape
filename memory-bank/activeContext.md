# Active Context

## Current Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

## Recent Changes (Mar 29, 2026) — Alphabetical Lookup Grids, Track Duration Fix, Hook Fix

- **Alphabetical ordering on lookup table grids** — Added `.order(:name)` to the `index` action of all six lookup controllers (EditionsController, GenresController, MediaController, PhasesController, PrioritiesController, ReleaseTypesController). Grids now always display in alphabetical order instead of database insertion order.
- **Track form duration field fix** — Replaced `numberfield` with the existing custom `durationfield` component in `TrackDetail.js`. The Track form now accepts `m:ss` input (e.g., "3:34" → 214 seconds) and displays existing durations in `m:ss` format, matching the Album Details tracklist behavior. Added `mixtape.view.common.DurationField` to the `requires` array.
- **Branch guard hook fix** — Both repos' `.claude/hooks/guard-branch.sh` now resolve the repo directory from the hook script's own location (`REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"`) and use `git -C "$REPO_DIR"` instead of bare `git`. This ensures the branch check targets the correct repo even when Claude Code's working directory is a different repo (e.g., backend CWD while editing frontend files).

## Recent Changes (Mar 29, 2026) — Branch Guard Hook

- **PreToolUse hook** (`.claude/hooks/guard-branch.sh`) — Blocks `Edit` and `Write` tools when on protected branches (`mixtape-develop`/`main` on backend, `mixtape-dev`/`main` on frontend). Exits with code 2 and a stderr message showing the branch naming convention. The agent then uses `Bash` (not matched by the hook) to pull latest and create a working branch before retrying the edit.
- **Hook configuration** in `.claude/settings.local.json` — `PreToolUse` event with `Edit|Write` matcher. Settings file also contains MCP server enablement and permission rules.
- **Key fix during implementation:** The original hook attempted interactive `/dev/tty` prompts to ask for a branch name. This hung in Claude Code's hook environment because `/dev/tty` is available (the process has a terminal) but `read` blocks waiting for keyboard input that can never arrive. Claude Code timed out the hook and allowed the edit through. Fixed by removing all `/dev/tty` logic and using only exit code 2 (block) with stderr messaging.
- **Both repos updated** — Backend guards `mixtape-develop|main`, frontend guards `mixtape-dev|main`.

## Recent Changes (Mar 28, 2026) — Server-Side Grid Filtering & Search

- **ExtJsFilterable concern** (`app/controllers/concerns/ext_js_filterable.rb`) — Shared concern providing `apply_ext_filters(scope)` that parses Ext JS `filter` param (JSON array from gridfilters plugin) and `search` param (plain string from toolbar search). Supports six filter kinds:
  - `:string` — ILIKE substring match (case-insensitive)
  - `:number` — gt/lt/eq comparison operators
  - `:boolean` — true/false exact match
  - `:list` — Names sent from client → lookup IDs via model → `IN (ids)` query
  - `:habtm_string` — EXISTS subquery through join table with ILIKE on associated record
  - `:habtm_list` — EXISTS subquery through user-scoped join table with `IN (names)` on associated record
- **All three catalog controllers updated** — ArtistsController, AlbumsController, TracksController include `ExtJsFilterable`, define `FILTER_CONFIG` and `SEARCH_FIELDS` constants, and call `apply_ext_filters(@scope).distinct` in index actions
- **Artist filters:** name (string), genre_name (habtm_list via user_artist_genres), priority_name (list → Priority), phase_name (list → Phase), complete (boolean), rating (number). Search: artist name + genre name.
- **Album filters:** artist_name (habtm_string via albums_artists), title (string), rating (number), release_type_name (list → ReleaseType), medium_name (list → Medium), listened (boolean), year (number), genre_name (habtm_list via user_album_genres). Search: album title + artist name.
- **Track filters:** artist_name (habtm_string via artists_tracks), title (string), album_title (habtm_string via album_tracks), rating (number), medium_name (list → Medium), listened (boolean), genre_name (habtm_list via user_track_genres). Search: track title + artist name + album title.
- **Frontend stores** — Added `remoteFilter: true` to Artists, Albums, Tracks stores
- **Frontend grids** — Added `plugins: 'gridfilters'` and column `filter` configs to ArtistGrid, AlbumGrid, TrackGrid. List filters use existing lookup stores (genres, priorities, phases, releaseTypes, media) with `idField: 'name'` / `labelField: 'name'`.
- **Search toolbar** — Added search textfield with `buffer: 400` change listener and clear trigger to all three grids. Controllers (`onSearchChange`) set/remove `search` extraParam on the store proxy and reload.
- **Filter specs** — Three new spec files covering all filter kinds, text search, combined filters, edge cases (malformed params, empty filters, unknown properties), no-duplicate guarantees for HABTM joins, and user-scoped genre isolation.

## Recent Changes (Mar 27, 2026) — Non-CRUD E2E Tests & Bug Fixes

- **4 new E2E test files** (39 tests) covering non-CRUD functionality:
  - `e2e/ratings.spec.js` — Inline star rating click-to-rate in artist/album/track grids with persistence verification
  - `e2e/preferences.spec.js` — User preference fields (rating, priority, phase, release type, medium, listened/complete, year, duration) via detail panel with save + reload verification
  - `e2e/associations.spec.js` — Genre/tag tagfield assignment on artists, multi-artist album association, and genre auto-population when selecting artists on new albums/tracks
  - `e2e/tracklist.spec.js` — Add existing track via modal, inline track entry mode, remove track, and tracklist persistence after reload
- **Backend bug fix: `primary_key` on UserArtist/UserTrack genre/tag associations** — `has_many :user_artist_genres` and `:user_artist_tags` were missing `primary_key: :artist_id`, causing Rails to join on `user_artists.id` instead of `user_artists.artist_id`. Same issue on UserTrack. This broke genre/tag assignment via API. `UserAlbum` already had the correct `primary_key: :album_id`.
- **Frontend bug fix: Album model `year` field** — Added `allowNull: true` to prevent null→0 conversion. The Year form field has `minValue: 1500`, so year=0 made the form invalid and disabled the `formBind` Save button on any album without a year set.
- **New E2E helpers in `e2e/helpers/extjs.js`:**
  - `setFieldValue` — Sets field value waiting for combo/tag stores to load, then calls `form.isValid()` to re-evaluate `formBind` buttons
  - `getFieldValue` — Gets current value of a form field by name
  - `getRecordFieldValue` — Gets a field value from a store record by text search
  - `ensureRecordVisible` — Scrolls a grid record into view without clicking (avoids triggering detail panel)
- **Total E2E test count: 73** (was 34)

## Recent Changes (Mar 25, 2026) — Delete & Cascade E2E Tests

- **New E2E delete spec** — `e2e/delete.spec.js` with three `test.describe.serial` blocks covering:
  1. **Artist cascade delete** — Creates artist + album + track via API, deletes artist through UI, verifies cascade warning dialog text, confirms album/track removed from their respective views
  2. **Album non-cascade delete** — Creates artist + album + track, deletes album, verifies track and artist remain in their views
  3. **Track non-cascade delete** — Creates artist + track, deletes track, verifies artist remains
- **New E2E helpers** in `e2e/helpers/extjs.js`: `clickToolbarButton`, `confirmDialog`, `waitForStoreLoad`, `getGridRowCount`
- **Test data isolation** — Each serial block creates uniquely-named records via backend API (`page.request.post`), avoiding collisions with dev data

## Recent Changes (Mar 25, 2026) — Collection-Scoped Index & Cascade Delete

- **Index endpoints scoped to user collection** — `GET /artists`, `GET /albums`, and `GET /tracks` now only return records the current user has in their collection (via `joins(:user_artists)` / `joins(:user_albums)` / `joins(:user_tracks)` with `where(user_id: current_user.id)`). Previously returned all catalog records regardless of user membership.
- **Artist delete cascades** — `ArtistsController#destroy` now removes the user's `UserAlbum` and `UserTrack` records for the deleted artist's albums and tracks (within a transaction). Uses `destroy_all` so dependent callbacks fire on sub-join models (genres, tags). Album and Track deletes do NOT cascade.
- **New specs** — Collection-scoping tests for all three controllers (excluded-from-collection, other-user-excluded). Cascade delete tests for artist (albums, tracks, both, other-user-safe, catalog-records-preserved). No-cascade confirmation tests for album and track destroy.

## Recent Changes (Mar 24, 2026) — CRUD E2E Tests

- **Artist and Track E2E specs** — New `e2e/artists.spec.js` and `e2e/tracks.spec.js` covering grid loading (columns, rows, detail panel) plus serial CRUD lifecycle tests (create, update, delete) for each entity.
- **Album CRUD E2E tests** — Added `Album CRUD` serial block to `e2e/albums.spec.js` covering create (with year=2020 for form validation), update, and delete.
- **New helpers in `e2e/helpers/extjs.js`:**
  - `fillTextField` — Sets field values via ExtJS `field.setValue()` component API (avoids `pressSequentially` character-dropping under load)
  - `clickButton` — Clicks ExtJS buttons by visible text
  - `confirmDialog` — Clicks "Yes" on Ext.Msg.confirm dialogs
  - `waitForToast` — Waits for Ext.toast messages
  - `waitForStoreRecord` — Verifies records exist in ExtJS store data (not DOM)
  - `selectGridRecord` — Finds record in store, scrolls into view with `ensureVisible`, then DOM-clicks the row (handles buffered/virtual rendering)
- **Key implementation details:**
  - Delete removes preferences (UserArtist/UserAlbum/UserTrack), not catalog records — row disappears from grid (index is collection-scoped). Artist delete cascades to remove user's associated album/track preferences.
  - Album `formBind: true` requires year to be set (minValue: 1500 validation)
  - Store-based verification (`waitForStoreRecord`) avoids DOM rendering race conditions
  - `selectGridRecord` uses `ensureVisible` + DOM click to handle grids with many rows (buffered rendering)
- **Total E2E test count: 27** (4 smoke, 4 navigation, 3 albums view, 3 album CRUD, 3 artists view, 3 artist CRUD, 3 tracks view, 3 track CRUD, 1 auth setup)

## Recent Changes (Mar 22, 2026) — Test Orchestrator Commands

- **Test orchestrator slash commands** — Single-invocation write → run → fix cycle:
  - **Backend:** `/project:test-full` — writes RSpec spec, runs it, diagnoses/fixes failures, re-runs (up to 3 attempts)
  - **Frontend:** `/project:e2e-full` — writes Playwright spec, runs it, debugs with MCP browser tools, re-runs (up to 3 attempts)
  - Each orchestrator contains full inline logic (spec patterns, diagnosis checklists, MCP tool references) rather than delegating to sub-commands

## Recent Changes (Mar 22, 2026) — Test Sub-Agents

- **Claude Code Test Sub-Agents** — Two specialized testing sub-agents as slash commands:
  - **Backend:** `.claude/commands/test-write.md`, `test-run.md`, `test-debug.md` for RSpec testing
  - **Frontend:** `.claude/commands/e2e-write.md`, `e2e-run.md`, `e2e-debug.md` for Playwright E2E testing
  - **E2E helpers:** `e2e/helpers/extjs.js` with shared utilities (`waitForExtReady`, `navigateToView`, ComponentQuery wrappers)
  - **Frontend MCP config:** Added `.mcp.json` to frontend repo for Playwright MCP access
  - Existing E2E tests refactored to use shared helpers

## Recent Changes (Mar 22, 2026) — E2E Testing

- **Playwright E2E Testing & MCP Server** — Added full-stack browser testing infrastructure:
  - **Frontend:** Installed Playwright in `mixtapeUI/mixtape/`, created `playwright.config.js` with auth setup + chromium projects, added E2E test suite (`e2e/auth.setup.js`, `smoke.spec.js`, `navigation.spec.js`, `albums.spec.js`). Tests use Ext JS CSS class selectors and text-based locators.
  - **Backend:** New `TestAuthController` with `POST /test/login` endpoint (dev/test only) that bypasses Cognito OAuth by setting `session[:user_id]` directly. Route guarded by `Rails.env.development? || Rails.env.test?`.
  - **MCP Server:** Added `.mcp.json` with `@playwright/mcp` server config for Claude Code browser automation during dev sessions.

## Recent Changes (Mar 13, 2026)

- **Default Edition per Album** — Users can now set a default edition that auto-selects when loading an album:
  - **Backend:** New `default_edition_id` column on `user_albums` (nullable FK to `editions`). `UserAlbum` model has `belongs_to :default_edition, class_name: 'Edition', optional: true`. AlbumsController permits `default_edition_id` in `preference_params` and includes it in `album_json` response. Two new RSpec tests (set and clear).
  - **Frontend:** "Default Edition" checkbox added to tracklist tbar (hidden when editions disabled). `onGridCellClick` auto-selects the default edition in the filter and checks the checkbox on album load. `onDefaultEditionChange` handler saves/clears via PUT (validates an edition is selected first). `onEditionFilterChange` syncs checkbox state using `_syncingDefaultEdition` guard flag. `onSaveClick` includes `default_edition_id` from the record in the save payload.

## Recent Changes (Mar 12, 2026)

- **Edition Management Modal (Phase 2)** — Full implementation of edition management:
  - **Backend:** New `PUT /albums/:id/edition_tracks` endpoint in AlbumsController. Accepts `{ edition_id, tracks: [{ track_id, position, disc_number }] }`. Handles removing tracks from edition (returns to unsorted), adding unsorted tracks to edition, creating new album_tracks for multi-edition tracks, and disc_number validation (consecutive from 1, no gaps). 13 new RSpec tests in `albums_controller_edition_tracks_spec.rb`.
  - **Frontend modal:** `EditionManagerModal.js` (Ext.window.Window) with border layout — edition selector tbar, edition tracks grid (center, sortable), available tracks grid (east), Up/Down reorder, Save/Close bbar.
  - **Frontend controller:** `EditionManagerController.js` with edition selection, dual-grid loading, add/remove between grids, reorder, renumber positions, dirty tracking (snapshot-based), save via API, and edition operations (Create New Edition, Copy To with Overwrite/Append/Cancel, Move To, Clear with confirmation).
  - **AlbumDetail.js:** Added "Manage Editions" button (hidden, shown when consider_editions enabled), added `EditionManagerModal` to requires.
  - **AlbumController.js:** `updateEditionVisibility` toggles the new button; `onManageEditionsClick` guards for saved albums, collects all album_tracks, creates/shows modal, listens for `editionsaved` to refresh tracklist.
  - **Route:** `resources :albums` changed to block with `member { put :edition_tracks }`.

## Recent Changes (Mar 10-11, 2026)

- **Inline track creation on album save (Phase 1)** — Full backend implementation of bulk track entry during album create/update. `handle_album_tracks` orchestrates album_track sync, `create_inline_track` creates Track + UserTrack with artist inheritance and genre transfer, `resolve_duplicate_title` handles same-title tracks. Frontend: tracklist grid with CellEditing plugin, "Enter Track Names" checkbox toggle, entry mode with `is_new` flag rows, typeahead combobox, DurationField widget, per-track artist editing for VA albums, edition filter/column. Backend commit: `0d0eb3f`.
- **Track CRUD frontend** — TrackGrid, TrackDetail, TrackController with full CRUD following the Artist/Album template pattern. Frontend commit: `679ab08`.
- **consider_editions toggle** — Per-user `consider_editions` boolean on UserAlbum. Frontend checkbox toggles edition filter dropdown and edition column visibility in tracklist grid. Backend commit: `96cc099`, frontend commit: `adf861d`.
- **DurationField custom widget** — `app/view/common/DurationField.js` — custom text field that parses "m:ss" input to seconds and displays seconds as "m:ss". Used in tracklist grid and track detail form.
- **various_artists boolean on Album** — Added catalog-level `various_artists` boolean to `albums` table. In JSON output, `artist_name` returns `['Various Artists']` when true, real artists otherwise. Frontend has "VA Collection" checkbox next to Artists tagfield; checking it disables/clears the artist tagfield. Commits: backend `98975d3`, frontend `c4db19f`.
- **Duplicate album title fix** — `Track#album_title` now uses `albums.distinct.map(&:title)` to prevent duplicate album names when a track appears on the same album via multiple editions. Commit: `da3ce04`.

## Inline Track Entry & Edition Management

**Status: Phase 1 & 2 complete. Phase 3 pending.**

### Implemented in Phase 1

1. **Checkbox toggle** ("Enter Track Names") switches the tracklist grid into entry mode — Title column becomes an editable typeahead combobox, new rows marked with `is_new` flag
2. **Artist inheritance** — Non-VA albums: album's `artist_ids` copied to each new track's `artists_tracks`. VA albums: per-track artist editing in the grid
3. **Genre transfer** — Album's user genres copied to new tracks at creation time only (one-time copy, no propagation) via `copy_album_genres_to_track`
4. **Rating + Listened** — Per-track star rating and listened checkbox in the grid (user_track preferences)
5. **Duration + ISRC** — Editable columns in the grid (catalog-level fields on tracks); DurationField widget parses "m:ss" to seconds
6. **Save timing** — All new tracks created on album save (single transactional request) via `handle_album_tracks`
7. **Duplicate handling** — Typeahead on track title to show existing catalog tracks. OS-style `(1)` suffix for same-title tracks on same album via `resolve_duplicate_title`

**Backend implementation (AlbumsController):**
- `handle_album_tracks(album)` — orchestrates album_track sync: splits submitted entries into existing (has `track_id`) vs new (has `title`, no `track_id`), removes album_tracks not in submitted list, syncs existing, creates new via `create_inline_track`
- `create_inline_track(at_params, existing_titles)` — creates Track + UserTrack, handles duplicate title resolution, inherits artist_ids from album (unless per-track for VA), copies album genres to track
- `copy_album_genres_to_track(user_track)` — propagates current album's user genres to newly created track
- `resolve_duplicate_title(title, existing_titles)` — appends `(n)` suffix for same-title tracks on same album

**Frontend implementation:**
- Album Detail tracklist grid with CellEditing plugin and entry mode toggle
- `is_new` flag rows for newly added tracks (unsaved until album save)
- Typeahead combobox for track title (searches existing catalog tracks)
- DurationField widget (`app/view/common/DurationField.js`) for m:ss parsing
- Per-track artist editing for VA albums
- Edition filter combobox and edition column (visibility tied to `consider_editions` checkbox)

### Phase 2: Edition Management Modal (Complete)

**Entry point:** "Manage Editions" button on the tracklist toolbar in Album Detail.

**Default edition:** Tracks without an edition keep `edition_id: null`. No sentinel record in the editions table. UI presents null-edition tracks as "Unsorted" in the available tracks pool.

**Modal layout:**
- **Edition selector** at top — dropdown of editions that have tracks populated on this album (not all editions in the catalog). Selecting an edition loads its tracks into the sortable list.
- **Sortable track list** (left/main panel) — tracks assigned to the selected edition, with up/down reorder buttons and per-track remove (returns track to available pool). Each track has an editable `disc_number` field (nullable integer) and `position` is derived from list order.
- **Available tracks pool** (right/secondary panel) — shows album tracks not assigned to the currently selected edition. Tracks can be on multiple editions simultaneously.

**Edition operations (buttons in modal toolbar):**
- **Create New Edition** — creates a new Edition record (catalog-level, visible to all users), same as the Editions lookup screen. Needed because edition names are not standardized.
- **Copy To** — copies all tracks from the current edition to a target edition (selected via dropdown showing all editions, including unpopulated ones). If the target already has tracks, a confirmation popup offers three choices: Overwrite, Append, or Cancel.
- **Move To** — same as Copy To, but clears the source edition after copying. Confirmation popup shows the same Overwrite/Append/Cancel options, with messaging that makes clear the source will also be cleared.
- **Clear** — removes all track assignments from the current edition (sets `edition_id: null` on those `AlbumTrack` rows, returning tracks to the unsorted pool). Confirmation popup: "Clear this edition? Are you sure?" Y/N.

**Edition dropdown scoping:**
- The edition selector in the modal and the edition filter on the Album Detail tracklist only show editions that have tracks populated on this album.
- The Copy To and Move To target dropdowns show all editions (including unpopulated ones), giving users the opportunity to bring in a different edition without cluttering the main dropdown.

**Save behavior:** Batch save — user arranges tracks, then saves all changes at once on confirm. Modal state is preserved on save failure with an error message.

**Validation on save:**
- Track positions are auto-renumbered from list order (position = index + 1). Removing a track renumbers the remaining tracks with no gaps.
- Disc numbers are validated for consecutive ordering with no gaps when present. Null disc numbers are allowed (single-disc albums don't need them).

**Catalog-level implications:** Editions and track-to-edition assignments live on `AlbumTrack` (shared catalog data). Any user with `consider_editions` enabled can modify edition assignments, affecting all users. This is intentional — editions are catalog metadata. Future consideration: admin curation layer where new editions are user-local until an admin promotes them to the catalog.

**New inline tracks:** Inherit the currently-selected edition filter value (or null if none) when created via the tracklist entry mode.

### Phase 3: CSV/Streaming Import (Pending)
- CSV/streaming import with ISRC-based deduplication

## Earlier Changes (Mar 2026)

- **Track data model refactor** — Major restructure of the Track model to support multiple artists and multiple albums per track:
  - Track `belongs_to :artist` replaced with HABTM `artists` (via `artists_tracks` join table, matching the Album/Artist pattern)
  - Track `belongs_to :album` replaced with `has_many :albums, through: :album_tracks` via new `AlbumTrack` join model (carries `position` and `disc_number` metadata)
  - Removed `artist_id`, `album_id`, `number`, `disc_number` columns from `tracks` table
  - Added `duration` (integer, seconds) and `isrc` (string, indexed) columns to `tracks` for future deduplication during CSV/streaming imports
  - `artist_name` and `album_title` now return arrays instead of single values
  - Data migrated from old columns to new join tables via reversible migrations
  - 6 migrations total: create `artists_tracks`, create `album_tracks`, add duration/isrc, migrate artist data, migrate album data, remove old columns
- **TracksController refactor** — Updated to match new data model:
  - `track_params` now permits `artist_ids: []`, `:duration`, `:isrc` (removed old column params)
  - Includes changed from `:artist, :album` to `:artists, :albums`
  - Added `handle_album_association` for creating/updating `AlbumTrack` records
  - Fixed pref.reload bug: `save!` now called before genre/tag sync (matching Artists/Albums pattern)
  - Extracted `track_json` helper method (matching `artist_json`/`album_json` pattern) with full ID arrays and preference data
- **UserTrack genre_name method** — Added missing `genre_name` method to `UserTrack` model (was already present on `UserAlbum` and `UserArtist`)
- **New AlbumTrack model** — Join model with `belongs_to :album`, `belongs_to :track`, uniqueness validation, and spec/factory
- **Updated specs** — Track spec, Artist spec, Track factory, TracksController spec all updated for new associations

### Earlier in Mar 2026
- **Album CRUD frontend** — Full create/update/delete UI for Albums in Ext.js, following the Artist template pattern. AlbumView (border layout), AlbumDetail (form panel), AlbumController (ViewController). Includes genre auto-populate from selected artists on new albums.
- **Album preference save order fix** — In AlbumsController `update`, moved `@user_pref.save!` before `update_album_genres`/`update_album_tags` to prevent `pref.reload` from discarding unsaved rating/listened changes. Same fix previously applied to ArtistsController.
- **Genre auto-populate** — When adding a new album, selecting artists auto-populates the genre tagfield with the union of those artists' genre_ids. Implemented via `change` listener on the artist_ids tagfield routing to `onArtistChange` in AlbumController. Only fires in phantom (new album) mode.
- **Explicit setValue after loadRecord** — Added explicit `ratingField.setValue()` calls after `form.loadRecord()` in both AlbumController and ArtistController, since `loadRecord` doesn't reliably set values on custom `Ext.form.field.Base` subclasses (StarRating) or tagfields.
- **Duplicate reference fix** — Removed unused `reference: 'mainContent'` from the center panel in Main.js. The `removeAll()`/`add()` navigation pattern triggered `[W] Duplicate reference` warnings during Ext JS's asynchronous reference cleanup.

## Older Changes (Feb 2026)

- **Artist CRUD frontend** — Full create/update/delete UI for Artists in Ext.js. Border layout with grid (center) and collapsible detail form panel (east). Uses `Ext.Ajax.request` with `jsonData` for full payload control. Designed as a reusable template pattern for other entities.
- **Star rating widget** — Reusable `StarRating` custom form field (`app/view/common/StarRating.js`) using FontAwesome 5 `fas fa-star` / `far fa-star` icons. Clickable stars in both the grid (inline save via AJAX) and detail form. Gold for filled, gray for empty.
- **JSON-only controllers** — Removed all `respond_to` blocks, `format.html` handlers, and `new`/`edit` actions from all 11 resource controllers. All endpoints now render JSON directly.
- **CORS credentials** — Added `credentials: true` to `cors.rb` and `withCredentials: true` to all Ext.js store/model proxies for cross-origin session cookies.
- **Preference save order fix** — In ArtistsController `update`, moved `@user_pref.save!` before `update_artist_genres`/`update_artist_tags` to prevent `pref.reload` from discarding unsaved attribute changes (rating, complete, priority, phase).
- **Backend JSON IDs** — ArtistsController now includes `priority_id`, `phase_id`, `genre_ids`, `tag_ids`, `tag_name` in JSON responses via `artist_json` helper.
- **User preference refactor** — Moved per-user metadata (ratings, genres, tags, listening flags) out of catalog models and into dedicated join models (UserArtist, UserAlbum, UserTrack) with sub-join models for genres and tags.
- **AWS Cognito integration** — Added OmniAuth OIDC authentication with Cognito, replacing any previous auth approach. Session-based with cookie store.
- **Minitest to RSpec migration** — Replaced Minitest with RSpec, FactoryBot, and Shoulda Matchers. Added model and controller specs.

## Known Issues

- **CI runs Minitest, not RSpec** — The GitHub Actions workflow still runs `bin/rails test test:system` instead of `bundle exec rspec`. Tests pass locally with RSpec but CI is running the wrong test framework.
- **CI installs sqlite3** — The `test` job in `ci.yml` runs `apt-get install sqlite3`, which is unnecessary since the project uses PostgreSQL. No PostgreSQL service is configured in CI either.
- **Inconsistent JSON rendering** — Catalog controllers use inline `as_json(only: [...]).merge(...)`. Lookup controllers use `render json: { data: @model }`. No serializer layer.
- **No pagination** — All list endpoints return every record. Will become a problem as the catalog grows.
- ~~**No backend filtering/search**~~ — Done. ExtJsFilterable concern provides server-side column filters and text search on all three catalog index endpoints.
- **Genre/tag sync duplication** — The `update_*_genres` and `update_*_tags` methods are copy-pasted across ArtistsController, AlbumsController, and TracksController with only model name differences.
- **Dockerfile references sqlite3** — The production Dockerfile (if present) may install sqlite3, a leftover from the Rails scaffold before PostgreSQL migration.
- **database.yml has stale SQLite comments** — The config file still contains commented-out SQLite configuration blocks.

## Open Questions

- **Lookup table access control** — Genre, Tag, Priority, Phase, Medium, Edition, and ReleaseType controllers have no authorization checks beyond `require_login`. Any authenticated user can create/delete lookup records that affect everyone. Should these be admin-only?
- ~~**HTML view removal**~~ — Done. All controllers now render JSON directly without `respond_to` blocks. The `new` and `edit` actions have been removed.
- **Artist, Album and Track deletion by Users** - It is likely that those classes will need need to be edited or deleted over time, perhaps only be an admin level user?
- **Create of Admin priveleges** - There are probably many reasons this will be needed.
