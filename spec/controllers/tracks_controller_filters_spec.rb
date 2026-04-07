require 'rails_helper'

RSpec.describe TracksController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index filtering' do
    # ── String filter ──────────────────────────────────────────────────

    context 'with title string filter' do
      it 'returns tracks matching the substring' do
        t1 = create(:track, title: 'Paranoid Android')
        t2 = create(:track, title: 'Schism')
        [t1, t2].each { |t| create(:user_track, user: user, track: t) }

        get :index, params: { filter: [{ property: 'title', value: 'Paranoid' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Paranoid Android'])
      end

      it 'is case-insensitive' do
        t = create(:track, title: 'Paranoid Android')
        create(:user_track, user: user, track: t)

        get :index, params: { filter: [{ property: 'title', value: 'paranoid' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Paranoid Android'])
      end
    end

    # ── HABTM string filters ──────────────────────────────────────────

    context 'with artist_name habtm string filter' do
      it 'filters tracks by artist name' do
        artist1 = create(:artist, name: 'Radiohead')
        artist2 = create(:artist, name: 'Tool')
        t1 = create(:track, title: 'Airbag')
        t2 = create(:track, title: 'Schism')
        t1.artists << artist1
        t2.artists << artist2
        [t1, t2].each { |t| create(:user_track, user: user, track: t) }

        get :index, params: { filter: [{ property: 'artist_name', value: 'Radio' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Airbag'])
      end

      it 'does not duplicate tracks with multiple matching artists' do
        a1 = create(:artist, name: 'Radio One')
        a2 = create(:artist, name: 'Radio Two')
        t = create(:track, title: 'Collab Song')
        t.artists << a1
        t.artists << a2
        create(:user_track, user: user, track: t)

        get :index, params: { filter: [{ property: 'artist_name', value: 'Radio' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Collab Song'])
      end
    end

    context 'with album_title habtm string filter' do
      it 'filters tracks by album title' do
        album1 = create(:album, title: 'OK Computer')
        album2 = create(:album, title: 'Lateralus')
        t1 = create(:track, title: 'Airbag')
        t2 = create(:track, title: 'Schism')
        create(:album_track, album: album1, track: t1)
        create(:album_track, album: album2, track: t2)
        [t1, t2].each { |t| create(:user_track, user: user, track: t) }

        get :index, params: { filter: [{ property: 'album_title', value: 'Computer' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Airbag'])
      end
    end

    # ── Number filter ──────────────────────────────────────────────────

    context 'with rating number filter' do
      it 'filters by greater than' do
        t1 = create(:track, title: 'Great Song')
        t2 = create(:track, title: 'OK Song')
        create(:user_track, user: user, track: t1, rating: 5)
        create(:user_track, user: user, track: t2, rating: 2)

        get :index, params: { filter: [{ property: 'rating', value: 3, operator: 'gt' }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Great Song'])
      end
    end

    # ── Boolean filter ─────────────────────────────────────────────────

    context 'with listened boolean filter' do
      it 'filters for listened tracks' do
        t1 = create(:track, title: 'Heard')
        t2 = create(:track, title: 'Unheard')
        create(:user_track, user: user, track: t1, listened: true)
        create(:user_track, user: user, track: t2, listened: false)

        get :index, params: { filter: [{ property: 'listened', value: true }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Heard'])
      end
    end

    # ── List filter ────────────────────────────────────────────────────

    context 'with medium_name list filter' do
      it 'filters by medium names' do
        vinyl = create(:medium, name: 'Vinyl', user: user)
        cd    = create(:medium, name: 'CD', user: user)
        t1 = create(:track, title: 'Analog Track', medium: vinyl)
        t2 = create(:track, title: 'Digital Track', medium: cd)
        [t1, t2].each { |t| create(:user_track, user: user, track: t) }

        get :index, params: { filter: [{ property: 'medium_name', value: ['Vinyl'] }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Analog Track'])
      end
    end

    # ── HABTM list filter (genres) ─────────────────────────────────────

    context 'with genre_name habtm list filter' do
      it 'filters by genre name' do
        rock = create(:genre, name: 'Rock', user: user)
        jazz = create(:genre, name: 'Jazz', user: user)
        t1 = create(:track, title: 'Rock Song')
        t2 = create(:track, title: 'Jazz Song')
        create(:user_track, user: user, track: t1)
        create(:user_track, user: user, track: t2)
        UserTrackGenre.create!(user: user, track: t1, genre: rock)
        UserTrackGenre.create!(user: user, track: t2, genre: jazz)

        get :index, params: { filter: [{ property: 'genre_name', value: ['Rock'] }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Rock Song'])
      end

      it 'scopes genres to the current user' do
        rock = create(:genre, name: 'Rock', user: user)
        other_user = create(:user)
        t = create(:track, title: 'Shared Track')
        create(:user_track, user: user, track: t)
        create(:user_track, user: other_user, track: t)
        UserTrackGenre.create!(user: other_user, track: t, genre: rock)

        get :index, params: { filter: [{ property: 'genre_name', value: ['Rock'] }].to_json }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to be_empty
      end
    end

    # ── Text search ────────────────────────────────────────────────────

    context 'with text search' do
      it 'searches by track title' do
        t1 = create(:track, title: 'Paranoid Android')
        t2 = create(:track, title: 'Schism')
        [t1, t2].each { |t| create(:user_track, user: user, track: t) }

        get :index, params: { search: 'Paranoid' }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Paranoid Android'])
      end

      it 'searches by artist name' do
        artist = create(:artist, name: 'Radiohead')
        t = create(:track, title: 'Airbag')
        t.artists << artist
        create(:user_track, user: user, track: t)

        get :index, params: { search: 'Radiohead' }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Airbag'])
      end

      it 'searches by album title' do
        album = create(:album, title: 'OK Computer')
        t = create(:track, title: 'Airbag')
        create(:album_track, album: album, track: t)
        create(:user_track, user: user, track: t)

        get :index, params: { search: 'Computer' }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Airbag'])
      end

      it 'does not return duplicates for tracks on multiple albums' do
        album1 = create(:album, title: 'Radio Album One')
        album2 = create(:album, title: 'Radio Album Two')
        t = create(:track, title: 'Hit Song')
        create(:album_track, album: album1, track: t)
        create(:album_track, album: album2, track: t)
        create(:user_track, user: user, track: t)

        get :index, params: { search: 'Radio Album' }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Hit Song'])
      end
    end

    # ── Combined filters ───────────────────────────────────────────────

    context 'with combined filters and search' do
      it 'combines column filter with text search using AND' do
        artist = create(:artist, name: 'Radiohead')
        t1 = create(:track, title: 'Airbag')
        t2 = create(:track, title: 'Lucky')
        t1.artists << artist
        t2.artists << artist
        create(:user_track, user: user, track: t1, listened: true)
        create(:user_track, user: user, track: t2, listened: false)

        get :index, params: {
          filter: [{ property: 'listened', value: true }].to_json,
          search: 'Radiohead'
        }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Airbag'])
      end

      it 'combines multiple column filters with AND' do
        vinyl = create(:medium, name: 'Vinyl', user: user)
        t1 = create(:track, title: 'Perfect', medium: vinyl)
        t2 = create(:track, title: 'Good', medium: vinyl)
        t3 = create(:track, title: 'OK')
        create(:user_track, user: user, track: t1, rating: 5)
        create(:user_track, user: user, track: t2, rating: 2)
        create(:user_track, user: user, track: t3, rating: 5)

        get :index, params: {
          filter: [
            { property: 'medium_name', value: ['Vinyl'] },
            { property: 'rating', value: 3, operator: 'gt' }
          ].to_json
        }, format: :json
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Perfect'])
      end
    end

    # ── Edge cases ─────────────────────────────────────────────────────

    context 'edge cases' do
      it 'handles empty filter gracefully' do
        t = create(:track, title: 'Airbag')
        create(:user_track, user: user, track: t)

        get :index, params: { filter: '[]' }, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'handles malformed filter gracefully' do
        t = create(:track, title: 'Airbag')
        create(:user_track, user: user, track: t)

        get :index, params: { filter: 'invalid' }, format: :json
        expect(response).to have_http_status(:ok)
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Airbag'])
      end

      it 'handles empty search string gracefully' do
        t = create(:track, title: 'Airbag')
        create(:user_track, user: user, track: t)

        get :index, params: { search: '' }, format: :json
        expect(response).to have_http_status(:ok)
        titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
        expect(titles).to eq(['Airbag'])
      end
    end
  end
end
