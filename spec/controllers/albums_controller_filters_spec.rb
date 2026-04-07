require 'rails_helper'

RSpec.describe AlbumsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index filtering' do
    # ── String filter ──────────────────────────────────────────────────

    context 'with title string filter' do
      it 'returns albums matching the substring' do
        ab1 = create(:album, title: 'OK Computer')
        ab2 = create(:album, title: 'Kid A')
        [ab1, ab2].each { |a| create(:user_album, user: user, album: a) }

        get :index, params: { filter: [{ property: 'title', value: 'Computer' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['OK Computer'])
      end

      it 'is case-insensitive' do
        ab = create(:album, title: 'OK Computer')
        create(:user_album, user: user, album: ab)

        get :index, params: { filter: [{ property: 'title', value: 'ok computer' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['OK Computer'])
      end
    end

    # ── HABTM string filter (artist_name) ──────────────────────────────

    context 'with artist_name habtm string filter' do
      it 'filters albums by artist name substring' do
        artist1 = create(:artist, name: 'Radiohead')
        artist2 = create(:artist, name: 'Tool')
        ab1 = create(:album, title: 'OK Computer')
        ab2 = create(:album, title: 'Lateralus')
        ab1.artists << artist1
        ab2.artists << artist2
        [ab1, ab2].each { |a| create(:user_album, user: user, album: a) }

        get :index, params: { filter: [{ property: 'artist_name', value: 'Radio' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['OK Computer'])
      end

      it 'does not produce duplicate rows for multi-artist albums' do
        artist1 = create(:artist, name: 'Radio Artist One')
        artist2 = create(:artist, name: 'Radio Artist Two')
        ab = create(:album, title: 'Collab Album')
        ab.artists << artist1
        ab.artists << artist2
        create(:user_album, user: user, album: ab)

        get :index, params: { filter: [{ property: 'artist_name', value: 'Radio' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Collab Album'])
      end
    end

    # ── Number filters ─────────────────────────────────────────────────

    context 'with rating number filter' do
      it 'filters by greater than' do
        ab1 = create(:album, title: 'Great')
        ab2 = create(:album, title: 'Meh')
        create(:user_album, user: user, album: ab1, rating: 5)
        create(:user_album, user: user, album: ab2, rating: 2)

        get :index, params: { filter: [{ property: 'rating', value: 3, operator: 'gt' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Great'])
      end
    end

    context 'with year number filter' do
      it 'filters by equal year' do
        ab1 = create(:album, title: 'Old', year: 1997)
        ab2 = create(:album, title: 'New', year: 2020)
        [ab1, ab2].each { |a| create(:user_album, user: user, album: a) }

        get :index, params: { filter: [{ property: 'year', value: 1997, operator: 'eq' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Old'])
      end

      it 'filters by year range using gt and lt' do
        ab1 = create(:album, title: 'Nineties', year: 1997)
        ab2 = create(:album, title: 'Two Thousands', year: 2005)
        ab3 = create(:album, title: 'Twenty Twenties', year: 2021)
        [ab1, ab2, ab3].each { |a| create(:user_album, user: user, album: a) }

        get :index, params: {
          filter: [
            { property: 'year', value: 2000, operator: 'gt' },
            { property: 'year', value: 2010, operator: 'lt' }
          ].to_json
        }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Two Thousands'])
      end
    end

    # ── Boolean filter ─────────────────────────────────────────────────

    context 'with listened boolean filter' do
      it 'filters for listened albums' do
        ab1 = create(:album, title: 'Heard It')
        ab2 = create(:album, title: 'Not Yet')
        create(:user_album, user: user, album: ab1, listened: true)
        create(:user_album, user: user, album: ab2, listened: false)

        get :index, params: { filter: [{ property: 'listened', value: true }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Heard It'])
      end
    end

    # ── List filters ───────────────────────────────────────────────────

    context 'with release_type_name list filter' do
      it 'filters by release type names' do
        lp = create(:release_type, name: 'LP', user: user)
        ep = create(:release_type, name: 'EP', user: user)
        ab1 = create(:album, title: 'Full Length', release_type: lp)
        ab2 = create(:album, title: 'Short', release_type: ep)
        [ab1, ab2].each { |a| create(:user_album, user: user, album: a) }

        get :index, params: { filter: [{ property: 'release_type_name', value: ['LP'] }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Full Length'])
      end
    end

    context 'with medium_name list filter' do
      it 'filters by medium names' do
        vinyl = create(:medium, name: 'Vinyl', user: user)
        cd    = create(:medium, name: 'CD', user: user)
        ab1 = create(:album, title: 'Analog', medium: vinyl)
        ab2 = create(:album, title: 'Digital', medium: cd)
        [ab1, ab2].each { |a| create(:user_album, user: user, album: a) }

        get :index, params: { filter: [{ property: 'medium_name', value: ['Vinyl'] }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Analog'])
      end
    end

    # ── HABTM list filter (genres) ─────────────────────────────────────

    context 'with genre_name habtm list filter' do
      it 'filters by genre name' do
        rock = create(:genre, name: 'Rock', user: user)
        jazz = create(:genre, name: 'Jazz', user: user)
        ab1 = create(:album, title: 'Rock Album')
        ab2 = create(:album, title: 'Jazz Album')
        create(:user_album, user: user, album: ab1)
        create(:user_album, user: user, album: ab2)
        UserAlbumGenre.create!(user: user, album: ab1, genre: rock)
        UserAlbumGenre.create!(user: user, album: ab2, genre: jazz)

        get :index, params: { filter: [{ property: 'genre_name', value: ['Rock'] }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Rock Album'])
      end

      it 'scopes genres to the current user' do
        rock = create(:genre, name: 'Rock', user: user)
        other_user = create(:user)
        ab = create(:album, title: 'Shared Album')
        create(:user_album, user: user, album: ab)
        create(:user_album, user: other_user, album: ab)
        UserAlbumGenre.create!(user: other_user, album: ab, genre: rock)

        get :index, params: { filter: [{ property: 'genre_name', value: ['Rock'] }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to be_empty
      end
    end

    # ── Text search ────────────────────────────────────────────────────

    context 'with text search' do
      it 'searches by album title' do
        ab1 = create(:album, title: 'OK Computer')
        ab2 = create(:album, title: 'Lateralus')
        [ab1, ab2].each { |a| create(:user_album, user: user, album: a) }

        get :index, params: { search: 'Computer' }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['OK Computer'])
      end

      it 'searches by artist name on albums' do
        artist = create(:artist, name: 'Radiohead')
        ab = create(:album, title: 'OK Computer')
        ab.artists << artist
        create(:user_album, user: user, album: ab)

        get :index, params: { search: 'Radiohead' }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['OK Computer'])
      end

      it 'does not return duplicates for multi-artist albums' do
        artist1 = create(:artist, name: 'Radio One')
        artist2 = create(:artist, name: 'Radio Two')
        ab = create(:album, title: 'Joint Album')
        ab.artists << artist1
        ab.artists << artist2
        create(:user_album, user: user, album: ab)

        get :index, params: { search: 'Radio' }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['Joint Album'])
      end
    end

    # ── Combined filters ───────────────────────────────────────────────

    context 'with combined filters and search' do
      it 'combines column filter with text search using AND' do
        lp = create(:release_type, name: 'LP', user: user)
        artist = create(:artist, name: 'Radiohead')

        ab1 = create(:album, title: 'OK Computer', release_type: lp)
        ab2 = create(:album, title: 'Amnesiac', release_type: lp)
        ab3 = create(:album, title: 'Pablo Honey')
        ab1.artists << artist
        ab2.artists << artist
        ab3.artists << artist
        [ab1, ab2, ab3].each { |a| create(:user_album, user: user, album: a) }

        get :index, params: {
          filter: [{ property: 'release_type_name', value: ['LP'] }].to_json,
          search: 'Computer'
        }, format: :json
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['OK Computer'])
      end
    end

    # ── Edge cases ─────────────────────────────────────────────────────

    context 'edge cases' do
      it 'handles empty filter gracefully' do
        ab = create(:album, title: 'OK Computer')
        create(:user_album, user: user, album: ab)

        get :index, params: { filter: '[]' }, format: :json
        expect(response).to have_http_status(:ok)
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['OK Computer'])
      end

      it 'handles malformed filter gracefully' do
        ab = create(:album, title: 'OK Computer')
        create(:user_album, user: user, album: ab)

        get :index, params: { filter: '{bad}' }, format: :json
        expect(response).to have_http_status(:ok)
        titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
        expect(titles).to eq(['OK Computer'])
      end
    end
  end
end
