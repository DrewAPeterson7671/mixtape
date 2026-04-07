# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 7, 2026) — Sequence and Definition Columns on Lookup Entities

Added `sequence` (integer, nullable) column to all 5 lookup entities (editions, media, phases, priorities, release_types) for user-controlled display ordering. Added `definition` (text, nullable) column to phases and priorities for documenting personal meaning.

### Backend
- **Migration** (`20260407223441`): adds `sequence` integer to 5 tables, `definition` text to phases and priorities
- **Controllers** (5 files): index ordering changed from `.order(:name)` to `.order(Arel.sql('sequence ASC NULLS LAST, name ASC'))` — sequenced records sort first, then alphabetical fallback
- **Strong params**: editions/media/release_types permit `:sequence`; phases/priorities permit `:sequence, :definition`
- **Tests**: ordering specs (Zebra/Alpha/Beta/Apple pattern), create/update specs for sequence (all 5) and definition (phases/priorities); 525 backend tests pass

### Frontend (25 files)
- **Models** (5): added `sequence` field (`type: 'int', allowNull: true`) to all 5; `definition` field (`type: 'string'`) to Phase and Priority
- **Stores** (5): added custom `sorterFn` replicating NULLS LAST behavior for client-side sorting in combobox dropdowns
- **Grids** (5): added `#` column (sequence, width 60, centered) before Name; added Definition column (flex 1) to Phase and Priority grids (Name reduced from flex 2 to flex 1)
- **Detail forms** (5): added Sequence numberfield (minValue 1, no decimals) to all 5; added Definition textarea (grow 40-120) to Phase and Priority
- **Controllers** (5): `onSaveClick` values include `sequence` (all 5) and `definition` (phases/priorities, with `|| null` for empty string)

**Branches:** Backend `mixtape-develop-20260407_add_sequence_definition_to_lookups`, Frontend `mixtape-dev-20260407_add_sequence_definition_to_lookups`

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 6:** Simplified per-user lookup ownership (pure per-user model, no system records), no-var code style enforcement
- **Apr 5:** E2E test coverage expansion (~80 new tests), backend RSpec coverage gaps (420 tests passing), tracklist column visibility, show endpoint for full user track data
- **Apr 4:** `anyMatch: true` on all artist/track typeahead components (5 comboboxes)
- **Apr 1:** Safer E2E test cleanup strategy (user-scoped catalog record cleanup, orphan detection, transaction wrapping)
- **Mar 28-30:** Server-side grid filtering & search, Add Track UX, DurationField bug fix, E2E tests
- **Mar 24-27:** CRUD & non-CRUD E2E tests, collection-scoped endpoints, artist cascade delete
- **Mar 22:** Playwright E2E infrastructure, test sub-agents, test orchestrator commands
- **Mar 10-13:** Inline track creation, edition management, DurationField, `various_artists` boolean
- **Earlier:** Track data model refactor, Album/Artist CRUD frontend, star rating, Cognito auth, RSpec migration
