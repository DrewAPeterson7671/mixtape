Diagnose a specific test failure: $ARGUMENTS

## Instructions

1. Parse the failure description or spec file path from `$ARGUMENTS`
2. Read the failing spec file
3. Read the source code under test (model or controller)
4. Read relevant factories in `spec/factories/`
5. If `$ARGUMENTS` contains error output, analyze it directly
6. Otherwise, run the specific spec to reproduce the failure:
   ```
   bundle exec rspec path/to/spec_file.rb
   ```

## Diagnosis Checklist

- **Factory issue**: Is the factory valid? Does it create all required associations? Run `build(:factory_name).valid?` mentally.
- **Missing association**: Does the test create all necessary join records (UserAlbum, UserTrack, UserArtist) before making assertions about user preferences?
- **Wrong HTTP status**: Check the controller action — does it render the expected status code? Does `save` fail silently?
- **Changed API response shape**: Does the spec parse from `['data']`? Does the controller wrap in `{ data: ... }`?
- **Transaction rollback**: Is a `save!` failing inside a transaction and rolling everything back?
- **Preference save order**: Is `save!` called before genre/tag sync? (The `pref.reload` in sync methods discards unsaved changes.)
- **Auth**: Is `sign_in(user)` present? Is the test `type: :controller`?
- **Uniqueness violation**: Are factory sequences being used for unique fields?

## Resolution

After identifying the root cause, propose a targeted fix. Prefer fixing the spec if the source code behavior is correct. Prefer fixing the source code if the spec correctly describes expected behavior.
