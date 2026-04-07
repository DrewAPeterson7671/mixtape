require 'rails_helper'

RSpec.describe ArtistsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index filtering' do
    # ── String filter ──────────────────────────────────────────────────

    context 'with name string filter' do
      it 'returns artists matching the substring' do
        a1 = create(:artist, name: 'Radiohead')
        a2 = create(:artist, name: 'Radio Birdman')
        a3 = create(:artist, name: 'Tool')
        [a1, a2, a3].each { |a| create(:user_artist, user: user, artist: a) }

        get :index, params: { filter: [{ property: 'name', value: 'Radio' }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to contain_exactly('Radiohead', 'Radio Birdman')
      end

      it 'is case-insensitive' do
        a = create(:artist, name: 'Radiohead')
        create(:user_artist, user: user, artist: a)

        get :index, params: { filter: [{ property: 'name', value: 'radiohead' }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Radiohead'])
      end
    end

    # ── Number filter ──────────────────────────────────────────────────

    context 'with rating number filter' do
      it 'filters by greater than' do
        a1 = create(:artist, name: 'High')
        a2 = create(:artist, name: 'Low')
        create(:user_artist, user: user, artist: a1, rating: 5)
        create(:user_artist, user: user, artist: a2, rating: 2)

        get :index, params: { filter: [{ property: 'rating', value: 3, operator: 'gt' }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['High'])
      end

      it 'filters by less than' do
        a1 = create(:artist, name: 'High')
        a2 = create(:artist, name: 'Low')
        create(:user_artist, user: user, artist: a1, rating: 5)
        create(:user_artist, user: user, artist: a2, rating: 2)

        get :index, params: { filter: [{ property: 'rating', value: 3, operator: 'lt' }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Low'])
      end

      it 'filters by equal' do
        a1 = create(:artist, name: 'Match')
        a2 = create(:artist, name: 'No Match')
        create(:user_artist, user: user, artist: a1, rating: 3)
        create(:user_artist, user: user, artist: a2, rating: 5)

        get :index, params: { filter: [{ property: 'rating', value: 3, operator: 'eq' }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Match'])
      end
    end

    # ── Boolean filter ─────────────────────────────────────────────────

    context 'with complete boolean filter' do
      it 'filters for true' do
        a1 = create(:artist, name: 'Done')
        a2 = create(:artist, name: 'Not Done')
        create(:user_artist, user: user, artist: a1, complete: true)
        create(:user_artist, user: user, artist: a2, complete: false)

        get :index, params: { filter: [{ property: 'complete', value: true }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Done'])
      end

      it 'filters for false' do
        a1 = create(:artist, name: 'Done')
        a2 = create(:artist, name: 'Not Done')
        create(:user_artist, user: user, artist: a1, complete: true)
        create(:user_artist, user: user, artist: a2, complete: false)

        get :index, params: { filter: [{ property: 'complete', value: false }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Not Done'])
      end
    end

    # ── List filter ────────────────────────────────────────────────────

    context 'with priority_name list filter' do
      it 'filters by priority names' do
        high = create(:priority, name: 'High', user: user)
        low  = create(:priority, name: 'Low', user: user)
        a1 = create(:artist, name: 'Urgent')
        a2 = create(:artist, name: 'Chill')
        a3 = create(:artist, name: 'None')
        create(:user_artist, user: user, artist: a1, priority: high)
        create(:user_artist, user: user, artist: a2, priority: low)
        create(:user_artist, user: user, artist: a3, priority: nil)

        get :index, params: { filter: [{ property: 'priority_name', value: ['High'] }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Urgent'])
      end

      it 'supports multiple selections' do
        high = create(:priority, name: 'High', user: user)
        low  = create(:priority, name: 'Low', user: user)
        a1 = create(:artist, name: 'Urgent')
        a2 = create(:artist, name: 'Chill')
        create(:user_artist, user: user, artist: a1, priority: high)
        create(:user_artist, user: user, artist: a2, priority: low)

        get :index, params: { filter: [{ property: 'priority_name', value: ['High', 'Low'] }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to contain_exactly('Urgent', 'Chill')
      end
    end

    context 'with phase_name list filter' do
      it 'filters by phase names' do
        phase = create(:phase, name: 'Exploring', user: user)
        a1 = create(:artist, name: 'In Phase')
        a2 = create(:artist, name: 'No Phase')
        create(:user_artist, user: user, artist: a1, phase: phase)
        create(:user_artist, user: user, artist: a2, phase: nil)

        get :index, params: { filter: [{ property: 'phase_name', value: ['Exploring'] }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['In Phase'])
      end
    end

    # ── HABTM list filter (genres) ─────────────────────────────────────

    context 'with genre_name habtm list filter' do
      it 'filters by genre name' do
        rock = create(:genre, name: 'Rock', user: user)
        jazz = create(:genre, name: 'Jazz', user: user)
        a1 = create(:artist, name: 'Rocker')
        a2 = create(:artist, name: 'Jazzer')
        ua1 = create(:user_artist, user: user, artist: a1)
        ua2 = create(:user_artist, user: user, artist: a2)
        UserArtistGenre.create!(user: user, artist: a1, genre: rock)
        UserArtistGenre.create!(user: user, artist: a2, genre: jazz)

        get :index, params: { filter: [{ property: 'genre_name', value: ['Rock'] }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Rocker'])
      end

      it 'scopes genres to the current user' do
        rock = create(:genre, name: 'Rock', user: user)
        other_user = create(:user)
        a = create(:artist, name: 'Shared Artist')
        create(:user_artist, user: user, artist: a)
        create(:user_artist, user: other_user, artist: a)
        # Only other_user has the Rock genre on this artist
        UserArtistGenre.create!(user: other_user, artist: a, genre: rock)

        get :index, params: { filter: [{ property: 'genre_name', value: ['Rock'] }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to be_empty
      end
    end

    # ── Text search ────────────────────────────────────────────────────

    context 'with text search' do
      it 'searches by artist name' do
        a1 = create(:artist, name: 'Radiohead')
        a2 = create(:artist, name: 'Tool')
        [a1, a2].each { |a| create(:user_artist, user: user, artist: a) }

        get :index, params: { search: 'radio' }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Radiohead'])
      end

      it 'searches by genre name' do
        rock = create(:genre, name: 'Progressive Rock', user: user)
        a = create(:artist, name: 'Dream Theater')
        create(:user_artist, user: user, artist: a)
        UserArtistGenre.create!(user: user, artist: a, genre: rock)

        get :index, params: { search: 'Progressive' }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Dream Theater'])
      end

      it 'does not return duplicates for multi-genre artists' do
        rock = create(:genre, name: 'Rock', user: user)
        alt  = create(:genre, name: 'Alternative Rock', user: user)
        a = create(:artist, name: 'Radiohead')
        create(:user_artist, user: user, artist: a)
        UserArtistGenre.create!(user: user, artist: a, genre: rock)
        UserArtistGenre.create!(user: user, artist: a, genre: alt)

        get :index, params: { search: 'Rock' }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Radiohead'])
      end
    end

    # ── Combined filters ───────────────────────────────────────────────

    context 'with multiple filters combined' do
      it 'combines column filters with AND logic' do
        high = create(:priority, name: 'High', user: user)
        a1 = create(:artist, name: 'High Complete')
        a2 = create(:artist, name: 'High Incomplete')
        a3 = create(:artist, name: 'Low Complete')
        create(:user_artist, user: user, artist: a1, priority: high, complete: true)
        create(:user_artist, user: user, artist: a2, priority: high, complete: false)
        create(:user_artist, user: user, artist: a3, complete: true)

        get :index, params: {
          filter: [
            { property: 'priority_name', value: ['High'] },
            { property: 'complete', value: true }
          ].to_json
        }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['High Complete'])
      end

      it 'combines column filter with text search' do
        high = create(:priority, name: 'High', user: user)
        a1 = create(:artist, name: 'Radiohead')
        a2 = create(:artist, name: 'Radio Birdman')
        a3 = create(:artist, name: 'Tool')
        create(:user_artist, user: user, artist: a1, priority: high)
        create(:user_artist, user: user, artist: a2)
        create(:user_artist, user: user, artist: a3, priority: high)

        get :index, params: {
          filter: [{ property: 'priority_name', value: ['High'] }].to_json,
          search: 'Radio'
        }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Radiohead'])
      end
    end

    # ── Edge cases ─────────────────────────────────────────────────────

    context 'edge cases' do
      it 'returns all data when filter param is empty JSON array' do
        a = create(:artist, name: 'Radiohead')
        create(:user_artist, user: user, artist: a)

        get :index, params: { filter: '[]' }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Radiohead'])
      end

      it 'returns all data when filter param is malformed' do
        a = create(:artist, name: 'Radiohead')
        create(:user_artist, user: user, artist: a)

        get :index, params: { filter: 'not-json' }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Radiohead'])
      end

      it 'ignores unknown filter properties' do
        a = create(:artist, name: 'Radiohead')
        create(:user_artist, user: user, artist: a)

        get :index, params: { filter: [{ property: 'bogus', value: 'x' }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['Radiohead'])
      end

      it 'returns empty when search matches nothing' do
        a = create(:artist, name: 'Radiohead')
        create(:user_artist, user: user, artist: a)

        get :index, params: { search: 'zzzzz' }, format: :json
        json = JSON.parse(response.body)['data']
        expect(json).to be_empty
      end

      it 'escapes LIKE wildcards in search terms' do
        a1 = create(:artist, name: '100% Pure')
        a2 = create(:artist, name: '100 Proof')
        [a1, a2].each { |a| create(:user_artist, user: user, artist: a) }

        get :index, params: { search: '100%' }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['100% Pure'])
      end

      it 'escapes LIKE wildcards in column filter values' do
        a1 = create(:artist, name: '100% Pure')
        a2 = create(:artist, name: '100 Proof')
        [a1, a2].each { |a| create(:user_artist, user: user, artist: a) }

        get :index, params: { filter: [{ property: 'name', value: '100%' }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to eq(['100% Pure'])
      end

      it 'returns all results when number filter has unknown operator' do
        a1 = create(:artist, name: 'One')
        a2 = create(:artist, name: 'Two')
        create(:user_artist, user: user, artist: a1, rating: 3)
        create(:user_artist, user: user, artist: a2, rating: 5)

        get :index, params: { filter: [{ property: 'rating', value: 3, operator: 'bogus' }].to_json }, format: :json
        names = JSON.parse(response.body)['data'].map { |a| a['name'] }
        expect(names).to contain_exactly('One', 'Two')
      end

      it 'returns no results when list filter values match no lookup records' do
        a = create(:artist, name: 'Radiohead')
        create(:user_artist, user: user, artist: a)

        get :index, params: { filter: [{ property: 'priority_name', value: ['Nonexistent'] }].to_json }, format: :json
        json = JSON.parse(response.body)['data']
        expect(json).to be_empty
      end
    end
  end
end
