# Active Context

## Base Branches

- **Backend:** `mixtape-develop`
- **Frontend:** `mixtape-dev`

Working branches are created off these for each feature (e.g., `mixtape-develop-20260403_default_listing_order`).

## Recent Changes (Apr 12, 2026) — CreatableTagField E2E Tests

Added Playwright E2E tests for the `CreatableTagField` inline entity creation feature.

- **New spec:** `e2e/creatable-tagfield.spec.js` — 5 tests in a `test.describe.serial` block covering:
  - Create a new genre via the "+" trigger (verifies real numeric ID, not phantom)
  - Duplicate detection selects existing record instead of creating a new one
  - Create a new tag via the "+" trigger
  - Save and verify persistence (navigate away and back, re-select, assert values)
  - Create a new artist via Related Artists "+" trigger
- **Testing approach:** `page.evaluate()` calls `field.onCreateClick()` to trigger the prompt dialog; `.x-message-box` selectors for `Ext.Msg.prompt` interaction; `waitForFunction` to wait for AJAX completion and value population

## Earlier (Apr 12, 2026) — Inline Entity Creation via CreatableTagField

Added a reusable `CreatableTag` component (`widget.creatabletagfield`) extending `Ext.form.field.Tag` with a "+" trigger button for inline creation of artists, genres, and tags without leaving the current form.

- **New component:** `app/view/common/CreatableTag.js` — configurable via `createUrl`, `createRoot`, `createTitle`, `createPrompt`; includes duplicate check (case-insensitive), POST to backend, auto-add to store + selection, error display
- **ArtistDetail.js:** Converted 3 tagfields (genres, tags, related artists) to `creatabletagfield`
- **AlbumDetail.js:** Converted 5 tagfields (form: artists, genres, tags; grid editors: artist, genre) to `creatabletagfield`
- **TrackDetail.js:** Converted 3 tagfields (artists, genres, tags) to `creatabletagfield`; `album_ids` left as plain tagfield (albums need more than a name)
- No backend changes — existing create endpoints already accept `{ name: "..." }` payloads

## Summary of Earlier Work

For full details on earlier changes, see git history. Key milestones:

- **Apr 8:** Album title uniqueness validation per artist; restore missing UserAlbum/UserTrack join records
- **Apr 7:** Sequence and definition columns on all lookup entities (5 backend + 26 frontend files), `remoteSort: false` fix for Ext JS stores
- **Apr 6:** Simplified per-user lookup ownership (pure per-user model, no system records), no-var code style enforcement
- **Apr 5:** E2E test coverage expansion (~80 new tests), backend RSpec coverage gaps (420 tests passing), tracklist column visibility, show endpoint for full user track data
- **Apr 4:** `anyMatch: true` on all artist/track typeahead components (5 comboboxes)
- **Apr 1:** Safer E2E test cleanup strategy (user-scoped catalog record cleanup, orphan detection, transaction wrapping)
- **Mar 28-30:** Server-side grid filtering & search, Add Track UX, DurationField bug fix, E2E tests
- **Mar 24-27:** CRUD & non-CRUD E2E tests, collection-scoped endpoints, artist cascade delete
- **Mar 22:** Playwright E2E infrastructure, test sub-agents, test orchestrator commands
- **Mar 10-13:** Inline track creation, edition management, DurationField, `various_artists` boolean
- **Earlier:** Track data model refactor, Album/Artist CRUD frontend, star rating, Cognito auth, RSpec migration
