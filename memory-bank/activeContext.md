# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 6, 2026) — System + User Ownership for Lookup Entities

Implemented a two-tier ownership model for all 7 lookup entities (Genre, Tag, Edition, Medium, Phase, Priority, ReleaseType):
- **System records** (`user_id = NULL`): visible to all users, read-only, seeded by developer
- **User records** (`user_id = N`): private to the creating user, fully editable/deletable

### Backend (migration, models, controllers, seeds, tests)
- **Migration** (`20260407012505`): adds nullable `user_id` FK to all 7 tables with partial unique indexes (system name uniqueness + per-user name uniqueness)
- **`UserOwnable` concern** (`app/models/concerns/user_ownable.rb`): `belongs_to :user, optional: true`, scopes (`visible_to`, `system_records`, `owned_by`), `system?`/`owned_by?` methods, custom uniqueness validation within visible set
- **`LookupAuthorizable` concern** (`app/controllers/concerns/lookup_authorizable.rb`): `authorize_ownership!` returns `true` for own records or `head :forbidden` + `false` for system/others; `lookup_json`/`lookup_collection_json` add `system` flag to JSON
- All 7 controllers updated: index scoped via `visible_to(current_user)`, create sets `user = current_user`, update/destroy guarded by `authorize_ownership!`
- **ExtJsFilterable** updated: `apply_list_filter` scopes lookup through `visible_to(current_user)` for UserOwnable models
- **Seed data**: system records for Genres (15), Media (5), Release Types (7), Editions (5), Phases (4), Priorities (4); Tags intentionally excluded
- **Tests**: shared examples `UserOwnable` and `LookupAuthorizable`; all 7 model/controller specs updated; 596 backend tests pass
- User model gains `has_many` for all 7 lookup entities with `dependent: :destroy`

### Frontend (models, grids, controllers)
- All 7 Ext JS models gain `system` boolean field (`persist: false`)
- All 7 grid files gain "Type" column with lock icon for system records (`<i class="fa fa-lock">`)
- 6 lookup ViewModels gain `isSystem: false` data binding (Tag has no ViewModel)
- 6 lookup controllers gain system guards: `onGridCellClick` sets name read-only + disables Save for system records; `onDeleteClick` blocks system record deletion; `onSaveClick` guards against `isSystem`

### E2E Tests
- 221 of 225 pass; 2 pre-existing failures in Artist/Album views (cancel-button detail collapse, cell-edit-gating artist combo sync) — unrelated to ownership changes

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
