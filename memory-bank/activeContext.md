# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 6, 2026) — Simplified Per-User Lookup Ownership

Simplified lookup entity ownership from two-tier system/user model to pure per-user ownership. Every lookup record now belongs to exactly one user — no system records, no sharing, no read-only records. New users get seeded defaults on first login via `after_create` callback.

### Backend
- **Migration** (`20260407022002`): deletes all system records (`user_id IS NULL`), seeds per-user defaults for each existing user, reassigns FK references (user_artist_genres etc.) from system to matching user records, drops partial indexes, adds unconditional `UNIQUE(name, user_id)` indexes, makes `user_id NOT NULL`
- **`UserOwnable` concern** simplified: `belongs_to :user` (required), `validates :name, uniqueness: { scope: :user_id }` — no scopes, no `system?`, no `visible_to`
- **`LookupAuthorizable` concern** deleted — no longer needed
- **User model** gains `after_create :seed_default_lookups` callback with default records: Genres (15), Media (5), Release Types (7), Editions (5), Phases (4), Priorities (4), Tags (none)
- All 7 lookup controllers simplified: scope through `current_user.{entity}` associations, no authorization guards, plain `render json: { data: ... }`
- **ExtJsFilterable** updated: uses `reflect_on_association(:user)` + `model.where(user_id: current_user.id)` instead of `visible_to`
- **Tests**: shared examples `UserOwnable` (simplified) and `PerUserLookup` (replaces `LookupAuthorizable`); user factory suppresses seed callback by default, `:with_default_lookups` trait for explicit testing; 506 backend tests pass

### Frontend
- Removed `system` boolean field from all 7 Ext JS models
- Removed "Type" column (lock icon) from all 7 grids
- Removed `isSystem` from 6 ViewModels
- Removed system guards from 6 controllers (all lookups are now freely editable/deletable)

### E2E Tests
- 219 of 225 pass; 1 pre-existing flaky failure (edition-manager-modal save persistence), 1 pre-existing failure in inline-track-genre-medium (cell editor visibility timing) — both unrelated to ownership changes

**Branches:** Backend `mixtape-develop-20260406_no_var_code_style`, Frontend changes in `mixtapeUI/mixtape`

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 6:** No-var code style enforcement across all 48 frontend JS files (906 var→const/let conversions)
- **Apr 5:** E2E test coverage expansion (~80 new tests), backend RSpec coverage gaps (420 tests passing), tracklist column visibility, show endpoint for full user track data
- **Apr 4:** `anyMatch: true` on all artist/track typeahead components (5 comboboxes)
- **Apr 1:** Safer E2E test cleanup strategy (user-scoped catalog record cleanup, orphan detection, transaction wrapping)
- **Mar 28-30:** Server-side grid filtering & search, Add Track UX, DurationField bug fix, E2E tests
- **Mar 24-27:** CRUD & non-CRUD E2E tests, collection-scoped endpoints, artist cascade delete
- **Mar 22:** Playwright E2E infrastructure, test sub-agents, test orchestrator commands
- **Mar 10-13:** Inline track creation, edition management, DurationField, `various_artists` boolean
- **Earlier:** Track data model refactor, Album/Artist CRUD frontend, star rating, Cognito auth, RSpec migration
