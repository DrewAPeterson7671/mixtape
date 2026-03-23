Full RSpec test cycle for: $ARGUMENTS

## Instructions

You are running a complete write → run → fix cycle for the specified model or controller. Follow each phase in order.

---

## Phase 1: Write Spec

1. Read the source file for the model or controller specified in `$ARGUMENTS`
2. Check if a spec already exists in `spec/models/` or `spec/controllers/` for this file
3. **If no spec exists**, generate one following the patterns below. **If a spec already exists**, skip to Phase 2.

### RSpec Controller Spec Pattern

Reference: `spec/controllers/albums_controller_spec.rb` (most comprehensive example)

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

### RSpec Model Spec Pattern

Reference: `spec/models/album_spec.rb`

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

### Key Conventions

- `sign_in(user)` helper from `spec/support/auth_helpers.rb` (only in `type: :controller` specs)
- `as: :json` format on all requests
- Parse response from `JSON.parse(response.body)['data']`
- Create join records explicitly for user preferences (UserAlbum, UserTrack, UserArtist)
- Test auth rejection separately: `session.delete(:user_id)` then expect 401
- Test index, show, create, update, destroy actions
- Test validation errors return 422
- Factory validation first in model specs
- Shoulda Matchers for associations: `have_many`, `belong_to`, `have_and_belong_to_many` with `.optional`, `.dependent(:destroy)`, `.through()`
- Shoulda Matchers for validations: `validate_presence_of`, `validate_numericality_of`

### Architecture Notes

- Catalog records (Artist, Album, Track) are shared across all users
- User-specific data (ratings, tags, genres, listened/explored flags) lives in join models: UserArtist, UserAlbum, UserTrack
- Always create the join record explicitly when testing endpoints that return user preferences
- Catalog controllers delete only the user preference on destroy, not the catalog record

### Factories

22 factories in `spec/factories/`. Use Faker for data, `sequence(:name)` for uniqueness, explicit associations. Check existing factories before creating test data.

---

## Phase 2: Run Spec

Run the spec:

```
bundle exec rspec spec/{models|controllers}/[name]_spec.rb
```

Capture the full output.

- If all tests pass, skip to Phase 5 (Report).
- If there are failures, proceed to Phase 3.

---

## Phase 3: Fix Failures

For each failure:

1. Read the failing spec file
2. Read the source code under test (model or controller)
3. Read relevant factories in `spec/factories/`
4. Diagnose using the checklist below
5. Apply a targeted fix to either the spec or the source code

### Diagnosis Checklist

- **Factory issue**: Is the factory valid? Does it create all required associations?
- **Missing association**: Does the test create all necessary join records (UserAlbum, UserTrack, UserArtist) before making assertions about user preferences?
- **Wrong HTTP status**: Check the controller action — does it render the expected status code? Does `save` fail silently?
- **Changed API response shape**: Does the spec parse from `['data']`? Does the controller wrap in `{ data: ... }`?
- **Transaction rollback**: Is a `save!` failing inside a transaction and rolling everything back?
- **Preference save order**: Is `save!` called before genre/tag sync? (The `pref.reload` in sync methods discards unsaved changes.)
- **Auth**: Is `sign_in(user)` present? Is the test `type: :controller`?
- **Uniqueness violation**: Are factory sequences being used for unique fields?

### Common Failure Patterns

- **Missing join record**: Tests that check user preferences need explicit `create(:user_album, user: user, album: album)` etc.
- **Response shape**: All catalog controllers wrap data in `{ "data": ... }`. Parse with `JSON.parse(response.body)['data']`.
- **Auth failures**: Controller specs need `sign_in(user)` in `before` block.
- **Factory collisions**: Use `sequence(:name)` in factories to avoid uniqueness constraint violations.

### Resolution

Prefer fixing the spec if the source code behavior is correct. Prefer fixing the source code if the spec correctly describes expected behavior.

---

## Phase 4: Re-run

Run the spec again:

```
bundle exec rspec spec/{models|controllers}/[name]_spec.rb
```

- If all tests pass, proceed to Phase 5.
- If failures remain, repeat Phase 3 with the new failure output.
- **Maximum 3 fix attempts.** If tests still fail after 3 rounds, proceed to Phase 5 and report the remaining failures.

---

## Phase 5: Report

Output a summary:

- **Target**: What was tested (model/controller name, spec file path)
- **Spec created**: Yes (new) or No (already existed)
- **Results**: Total tests, pass count, fail count
- **Fixes applied**: List each fix (what failed, what was changed, which attempt)
- **Remaining failures**: Any tests still failing after 3 attempts, with diagnosis

## Environment Notes

- PostgreSQL runs on port 5433 (dev) or default port (test)
- Ruby 3.4.2 via rbenv — if `bundle exec` fails with version errors, ask the user to run directly in their terminal
- Test database: `mixtape_test`
