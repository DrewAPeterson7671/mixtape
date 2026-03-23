Run RSpec tests and analyze results.

## Instructions

Run the test suite and analyze any failures:

1. If `$ARGUMENTS` specifies a file path, run that specific spec:
   ```
   bundle exec rspec $ARGUMENTS
   ```
2. If `$ARGUMENTS` is empty, run the full suite:
   ```
   bundle exec rspec
   ```
3. Read the output carefully
4. For any failures:
   - Read the failing spec file
   - Read the source code under test
   - Read relevant factories in `spec/factories/`
   - Identify the root cause (factory issue, missing association, wrong HTTP status, changed API response shape, etc.)
   - Propose a targeted fix to either the spec or the source code

## Environment Notes

- PostgreSQL must be running on port 5433 (dev) or default port (test)
- Ruby 3.4.2 via rbenv — if `bundle exec` fails with version errors, ask the user to run directly in their terminal
- Test database: `mixtape_test`

## Common Failure Patterns

- **Missing join record**: Tests that check user preferences need explicit `create(:user_album, user: user, album: album)` etc.
- **Response shape**: All catalog controllers wrap data in `{ "data": ... }`. Parse with `JSON.parse(response.body)['data']`.
- **Auth failures**: Controller specs need `sign_in(user)` in `before` block. Auth helper only available in `type: :controller` specs.
- **Factory collisions**: Use `sequence(:name)` in factories to avoid uniqueness constraint violations.
