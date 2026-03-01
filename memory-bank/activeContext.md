# Active Context

## Current Branch

`mixtape-develop` — main development branch.

## Recent Changes (Feb 2026)

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
- **No backend filtering/search** — Index endpoints return all records; filtering happens client-side only.
- **Genre/tag sync duplication** — The `update_*_genres` and `update_*_tags` methods are copy-pasted across ArtistsController, AlbumsController, and TracksController with only model name differences.
- **Preference save order (Albums/Tracks)** — The `pref.reload` bug fixed in ArtistsController also exists in AlbumsController and TracksController. `save!` should be moved before genre/tag sync in those controllers too.
- **Dockerfile references sqlite3** — The production Dockerfile (if present) may install sqlite3, a leftover from the Rails scaffold before PostgreSQL migration.
- **database.yml has stale SQLite comments** — The config file still contains commented-out SQLite configuration blocks.

## Open Questions

- **Lookup table access control** — Genre, Tag, Priority, Phase, Medium, Edition, and ReleaseType controllers have no authorization checks beyond `require_login`. Any authenticated user can create/delete lookup records that affect everyone. Should these be admin-only?
- ~~**HTML view removal**~~ — Done. All controllers now render JSON directly without `respond_to` blocks. The `new` and `edit` actions have been removed.
- **Artist, Album and Track deletion by Users** - It is likely that those classes will need need to be edited or deleted over time, perhaps only be an admin level user?
- **Create of Admin priveleges** - There are probably many reasons this will be needed.
