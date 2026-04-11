require 'rails_helper'

RSpec.describe AlbumsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array of albums with user preferences' do
      album = create(:album, title: 'OK Computer')
      create(:user_album, user: user, album: album, rating: 5, listened: true)
      get :index, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      entry = json.find { |a| a['id'] == album.id }
      expect(entry['title']).to eq('OK Computer')
      expect(entry['rating']).to eq(5)
      expect(entry['listened']).to eq(true)
    end

    it 'includes album_tracks with edition data' do
      album = create(:album, title: 'OK Computer')
      edition = create(:edition, name: 'Deluxe')
      track = create(:track, title: 'Airbag', duration: 284)
      create(:album_track, album: album, track: track, position: 1, disc_number: 1, edition: edition)
      create(:user_album, user: user, album: album)

      get :index, as: :json
      entry = JSON.parse(response.body)['data'].find { |a| a['id'] == album.id }
      expect(entry['album_tracks']).to be_an(Array)
      at = entry['album_tracks'].first
      expect(at['track_id']).to eq(track.id)
      expect(at['track_title']).to eq('Airbag')
      expect(at['edition_id']).to eq(edition.id)
      expect(at['edition_name']).to eq('Deluxe')
      expect(at['position']).to eq(1)
      expect(at['duration']).to eq(284)
    end

    it 'does not include edition_id at the album level' do
      album = create(:album, title: 'OK Computer')
      create(:user_album, user: user, album: album)
      get :index, as: :json
      entry = JSON.parse(response.body)['data'].find { |a| a['id'] == album.id }
      expect(entry).not_to have_key('edition_id')
      expect(entry).not_to have_key('edition_name')
    end

    it 'excludes albums not in user collection' do
      in_collection = create(:album, title: 'In Collection')
      create(:user_album, user: user, album: in_collection)
      create(:album, title: 'Not In Collection')

      get :index, as: :json
      json = JSON.parse(response.body)['data']
      titles = json.map { |a| a['title'] }
      expect(titles).to include('In Collection')
      expect(titles).not_to include('Not In Collection')
    end

    it 'sorts by artist name then album title, stripping articles' do
      beatles = create(:artist, name: 'The Beatles')
      arcade  = create(:artist, name: 'Arcade Fire')

      abbey = create(:album, title: 'Abbey Road')
      abbey.artists << beatles
      create(:user_album, user: user, album: abbey)

      funeral = create(:album, title: 'Funeral')
      funeral.artists << arcade
      create(:user_album, user: user, album: funeral)

      let_it = create(:album, title: 'Let It Be')
      let_it.artists << beatles
      create(:user_album, user: user, album: let_it)

      get :index, as: :json
      titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
      expect(titles).to eq(['Funeral', 'Abbey Road', 'Let It Be'])
    end

    it 'sorts VA albums under "various artists"' do
      artist = create(:artist, name: 'Aardvark')
      normal = create(:album, title: 'Normal Album')
      normal.artists << artist
      create(:user_album, user: user, album: normal)

      va = create(:album, title: 'VA Compilation', various_artists: true)
      create(:user_album, user: user, album: va)

      get :index, as: :json
      titles = JSON.parse(response.body)['data'].map { |a| a['title'] }
      expect(titles).to eq(['Normal Album', 'VA Compilation'])
    end

    it 'excludes albums belonging to another user' do
      other_user = create(:user)
      my_album = create(:album, title: 'Mine')
      other_album = create(:album, title: 'Theirs')
      create(:user_album, user: user, album: my_album)
      create(:user_album, user: other_user, album: other_album)

      get :index, as: :json
      json = JSON.parse(response.body)['data']
      titles = json.map { |a| a['title'] }
      expect(titles).to include('Mine')
      expect(titles).not_to include('Theirs')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single album JSON with album_tracks' do
      album = create(:album, title: 'OK Computer')
      track = create(:track, title: 'Paranoid Android')
      create(:album_track, album: album, track: track, position: 2, disc_number: 1)
      get :show, params: { id: album.id }, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('OK Computer')
      expect(json['album_tracks']).to be_an(Array)
      expect(json['album_tracks'].first['track_title']).to eq('Paranoid Android')
    end
  end

  describe 'POST #create' do
    it 'creates an Album and UserAlbum and returns 201' do
      expect {
        post :create, params: { album: { title: 'New Album', year: 2020, rating: 4 } }, as: :json
      }.to change(Album, :count).by(1).and change(UserAlbum, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('New Album')
      expect(json['rating']).to eq(4)
    end

    it 'creates album_tracks with correct edition_id' do
      track = create(:track, title: 'Lucky')
      edition = create(:edition, name: 'Original')

      post :create, params: {
        album: {
          title: 'OK Computer',
          album_tracks: [
            { track_id: track.id, position: 1, disc_number: 1, edition_id: edition.id }
          ]
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['album_tracks'].length).to eq(1)
      at = json['album_tracks'].first
      expect(at['track_id']).to eq(track.id)
      expect(at['edition_id']).to eq(edition.id)
      expect(at['position']).to eq(1)
    end

    it 'saves and returns notes and wikipedia fields' do
      post :create, params: {
        album: { title: 'Annotated Album', notes: 'Great debut album', wikipedia: 'https://en.wikipedia.org/wiki/Annotated_Album' }
      }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['notes']).to eq('Great debut album')
      expect(json['wikipedia']).to eq('https://en.wikipedia.org/wiki/Annotated_Album')
    end

    it 'returns 422 with invalid params' do
      post :create, params: { album: { title: '' } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when creating a duplicate title for the same artist' do
      artist = create(:artist, name: 'New Order')
      existing = create(:album, title: 'Movement')
      existing.artists << artist

      post :create, params: { album: { title: 'Movement', artist_ids: [artist.id] } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'creates inline tracks when album_tracks have title but no track_id' do
      expect {
        post :create, params: {
          album: {
            title: 'Inline Album',
            album_tracks: [
              { title: 'Song One', position: 1, disc_number: 1 },
              { title: 'Song Two', position: 2, disc_number: 1, duration: 225, isrc: 'US1234567890' }
            ]
          }
        }, as: :json
      }.to change(Track, :count).by(2).and change(AlbumTrack, :count).by(2)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      titles = json['album_tracks'].map { |at| at['track_title'] }
      expect(titles).to contain_exactly('Song One', 'Song Two')

      song_two = json['album_tracks'].find { |at| at['track_title'] == 'Song Two' }
      expect(song_two['duration']).to eq(225)
      expect(song_two['isrc']).to eq('US1234567890')
    end

    it 'inherits album artists for inline tracks on non-VA albums' do
      artist = create(:artist, name: 'Radiohead')

      post :create, params: {
        album: {
          title: 'Artist Inherit Album',
          artist_ids: [ artist.id ],
          album_tracks: [
            { title: 'Inherited Track', position: 1, disc_number: 1 }
          ]
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      at = json['album_tracks'].first
      expect(at['artist_ids']).to eq([ artist.id ])
      expect(at['artist_name']).to eq([ 'Radiohead' ])
    end

    it 'assigns per-track artists for VA album inline tracks' do
      artist1 = create(:artist, name: 'Artist A')
      artist2 = create(:artist, name: 'Artist B')

      post :create, params: {
        album: {
          title: 'VA Compilation',
          various_artists: true,
          album_tracks: [
            { title: 'Track A', position: 1, disc_number: 1, artist_ids: [ artist1.id ] },
            { title: 'Track B', position: 2, disc_number: 1, artist_ids: [ artist2.id ] }
          ]
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      track_a = json['album_tracks'].find { |at| at['track_title'] == 'Track A' }
      track_b = json['album_tracks'].find { |at| at['track_title'] == 'Track B' }
      expect(track_a['artist_ids']).to eq([ artist1.id ])
      expect(track_b['artist_ids']).to eq([ artist2.id ])
    end

    it 'transfers album genres to inline tracks' do
      genre = create(:genre, name: 'Rock')
      user_album = nil

      post :create, params: {
        album: {
          title: 'Genre Transfer Album',
          genre_ids: [ genre.id ],
          album_tracks: [
            { title: 'Genre Track', position: 1, disc_number: 1 }
          ]
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      track_id = json['album_tracks'].first['track_id']
      track_genres = UserTrackGenre.where(user: user, track_id: track_id).pluck(:genre_id)
      expect(track_genres).to include(genre.id)
    end

    it 'appends suffix for duplicate track titles' do
      track = create(:track, title: 'Untitled')

      post :create, params: {
        album: {
          title: 'Dupe Title Album',
          album_tracks: [
            { track_id: track.id, position: 1, disc_number: 1 },
            { title: 'Untitled', position: 2, disc_number: 1 }
          ]
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      titles = json['album_tracks'].map { |at| at['track_title'] }
      expect(titles).to include('Untitled')
      expect(titles).to include('Untitled (1)')
    end

    it 'handles mixed existing and new inline tracks' do
      existing_track = create(:track, title: 'Existing Song')

      expect {
        post :create, params: {
          album: {
            title: 'Mixed Album',
            album_tracks: [
              { track_id: existing_track.id, position: 1, disc_number: 1 },
              { title: 'New Song', position: 2, disc_number: 1 }
            ]
          }
        }, as: :json
      }.to change(Track, :count).by(1).and change(AlbumTrack, :count).by(2)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      titles = json['album_tracks'].map { |at| at['track_title'] }
      expect(titles).to contain_exactly('Existing Song', 'New Song')
    end

    it 'inherits medium_id from album for inline tracks' do
      medium = create(:medium, name: 'Vinyl')

      post :create, params: {
        album: {
          title: 'Medium Inherit Album',
          medium_id: medium.id,
          album_tracks: [
            { title: 'Vinyl Track', position: 1, disc_number: 1 }
          ]
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      track_id = json['album_tracks'].first['track_id']
      expect(Track.find(track_id).medium_id).to eq(medium.id)
    end

    it 'uses per-track genre_ids instead of copying album genres when provided' do
      album_genre = create(:genre, name: 'Rock')
      track_genre = create(:genre, name: 'Jazz')

      post :create, params: {
        album: {
          title: 'Genre Override Album',
          genre_ids: [album_genre.id],
          album_tracks: [
            { title: 'Custom Genre Track', position: 1, disc_number: 1, genre_ids: [track_genre.id] },
            { title: 'Default Genre Track', position: 2, disc_number: 1 }
          ]
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']

      custom_track_id = json['album_tracks'].find { |at| at['track_title'] == 'Custom Genre Track' }['track_id']
      default_track_id = json['album_tracks'].find { |at| at['track_title'] == 'Default Genre Track' }['track_id']

      custom_genres = UserTrackGenre.where(user: user, track_id: custom_track_id).pluck(:genre_id)
      expect(custom_genres).to eq([track_genre.id])
      expect(custom_genres).not_to include(album_genre.id)

      default_genres = UserTrackGenre.where(user: user, track_id: default_track_id).pluck(:genre_id)
      expect(default_genres).to eq([album_genre.id])
      expect(default_genres).not_to include(track_genre.id)
    end

    it 'creates UserTrack with listened and rating for inline tracks' do
      expect {
        post :create, params: {
          album: {
            title: 'Prefs Album',
            album_tracks: [
              { title: 'Rated Track', position: 1, disc_number: 1, listened: true, rating: 4 }
            ]
          }
        }, as: :json
      }.to change(UserTrack, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      at = json['album_tracks'].first
      expect(at['listened']).to eq(true)
      expect(at['rating']).to eq(4)
    end
  end

  describe 'PATCH #update' do
    it 'updates album and user preferences' do
      album = create(:album, title: 'Old Title')
      create(:user_album, user: user, album: album)
      patch :update, params: { id: album.id, album: { title: 'New Title', rating: 3, listened: true } }, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('New Title')
      expect(json['rating']).to eq(3)
      expect(json['listened']).to eq(true)
    end

    it 'syncs album_tracks: removes missing, updates existing, adds new' do
      album = create(:album, title: 'OK Computer')
      create(:user_album, user: user, album: album)
      edition = create(:edition, name: 'Original')
      track1 = create(:track, title: 'Airbag')
      track2 = create(:track, title: 'Paranoid Android')
      track3 = create(:track, title: 'Lucky')
      create(:album_track, album: album, track: track1, position: 1, disc_number: 1, edition: edition)
      create(:album_track, album: album, track: track2, position: 2, disc_number: 1, edition: edition)

      patch :update, params: {
        id: album.id,
        album: {
          title: 'OK Computer',
          album_tracks: [
            { track_id: track2.id, position: 1, disc_number: 1, edition_id: edition.id },
            { track_id: track3.id, position: 2, disc_number: 1, edition_id: edition.id }
          ]
        }
      }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      track_ids = json['album_tracks'].map { |at| at['track_id'] }
      expect(track_ids).to contain_exactly(track2.id, track3.id)
      expect(track_ids).not_to include(track1.id)

      updated = json['album_tracks'].find { |at| at['track_id'] == track2.id }
      expect(updated['position']).to eq(1)
    end

    it 'creates inline tracks on update' do
      album = create(:album, title: 'Update Album')
      create(:user_album, user: user, album: album)
      existing_track = create(:track, title: 'Old Track')
      create(:album_track, album: album, track: existing_track, position: 1, disc_number: 1)

      expect {
        patch :update, params: {
          id: album.id,
          album: {
            title: 'Update Album',
            album_tracks: [
              { track_id: existing_track.id, position: 1, disc_number: 1 },
              { title: 'New Inline Track', position: 2, disc_number: 1, duration: 180 }
            ]
          }
        }, as: :json
      }.to change(Track, :count).by(1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      titles = json['album_tracks'].map { |at| at['track_title'] }
      expect(titles).to contain_exactly('Old Track', 'New Inline Track')
    end

    it 'sets default_edition_id and returns it in the response' do
      album = create(:album, title: 'Edition Album')
      edition = create(:edition, name: 'Deluxe')
      create(:user_album, user: user, album: album)

      patch :update, params: { id: album.id, album: { default_edition_id: edition.id } }, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['default_edition_id']).to eq(edition.id)
    end

    it 'clears default_edition_id when set to nil' do
      album = create(:album, title: 'Edition Album')
      edition = create(:edition, name: 'Deluxe')
      create(:user_album, user: user, album: album, default_edition: edition)

      patch :update, params: { id: album.id, album: { default_edition_id: nil } }, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['default_edition_id']).to be_nil
    end

    it 'updates and returns notes and wikipedia fields' do
      album = create(:album, title: 'Plain Album')
      create(:user_album, user: user, album: album)

      patch :update, params: {
        id: album.id,
        album: { notes: 'Added later', wikipedia: 'https://en.wikipedia.org/wiki/Plain_Album' }
      }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['notes']).to eq('Added later')
      expect(json['wikipedia']).to eq('https://en.wikipedia.org/wiki/Plain_Album')
    end

    it 'leaves tracks unchanged when album_tracks key is not present' do
      album = create(:album, title: 'OK Computer')
      create(:user_album, user: user, album: album)
      track = create(:track, title: 'Airbag')
      create(:album_track, album: album, track: track, position: 1, disc_number: 1)

      patch :update, params: { id: album.id, album: { title: 'Updated Title' } }, as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['album_tracks'].length).to eq(1)
    end
  end

  describe 'DELETE #destroy' do
    it 'removes only the UserAlbum, not the Album' do
      album = create(:album)
      create(:user_album, user: user, album: album)
      expect {
        delete :destroy, params: { id: album.id }, as: :json
      }.to change(UserAlbum, :count).by(-1).and change(Album, :count).by(0)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not cascade to remove UserTrack records' do
      album = create(:album)
      track = create(:track)
      create(:album_track, album: album, track: track, position: 1)
      create(:user_album, user: user, album: album)
      create(:user_track, user: user, track: track)

      expect {
        delete :destroy, params: { id: album.id }, as: :json
      }.to change(UserAlbum, :count).by(-1).and change(UserTrack, :count).by(0)
    end
  end

  describe 'record not found' do
    it 'raises RecordNotFound for show with non-existent id' do
      expect {
        get :show, params: { id: -1 }, as: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises RecordNotFound for update with non-existent id' do
      expect {
        patch :update, params: { id: -1, album: { title: 'X' } }, as: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises RecordNotFound for destroy with non-existent id' do
      expect {
        delete :destroy, params: { id: -1 }, as: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'validation errors' do
    it 'returns 422 when creating an album with an invalid year' do
      post :create, params: { album: { title: 'Future Album', year: 3000 } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 when updating an album with an invalid year' do
      album = create(:album, title: 'Valid Album')
      create(:user_album, user: user, album: album)
      patch :update, params: { id: album.id, album: { year: 3000 } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'unauthenticated' do
    it 'returns 401 when not logged in' do
      session.delete(:user_id)
      get :index, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
