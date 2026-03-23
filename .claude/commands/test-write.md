Write a new RSpec spec for: $ARGUMENTS

## Instructions

1. Read the source file for the model or controller specified above
2. Read existing specs in `spec/models/` or `spec/controllers/` for the same file (if any exist) to avoid duplication
3. Generate a spec following the patterns below

## RSpec Controller Spec Pattern

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

Key conventions:
- `sign_in(user)` helper from `spec/support/auth_helpers.rb` (only in `type: :controller` specs)
- `as: :json` format on all requests
- Parse response from `JSON.parse(response.body)['data']`
- Create join records explicitly for user preferences (UserAlbum, UserTrack, UserArtist)
- Test auth rejection separately: `session.delete(:user_id)` then expect 401
- Test index, show, create, update, destroy actions
- Test validation errors return 422

## RSpec Model Spec Pattern

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

Key conventions:
- Factory validation first
- Shoulda Matchers for associations: `have_many`, `belong_to`, `have_and_belong_to_many` with `.optional`, `.dependent(:destroy)`, `.through()`
- Shoulda Matchers for validations: `validate_presence_of`, `validate_numericality_of`
- Test computed methods (e.g., `artist_name`, `medium_name`)

## Factories

22 factories in `spec/factories/`. Use Faker for data, `sequence(:name)` for uniqueness, explicit associations. Check existing factories before creating test data.

## Architecture Notes

- Catalog records (Artist, Album, Track) are shared across all users
- User-specific data (ratings, tags, genres, listened/explored flags) lives in join models: UserArtist, UserAlbum, UserTrack
- Always create the join record explicitly when testing endpoints that return user preferences
- Catalog controllers delete only the user preference on destroy, not the catalog record
- PostgreSQL runs on port 5433 for development, test DB uses default port
