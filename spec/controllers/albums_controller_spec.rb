require 'rails_helper'

RSpec.describe AlbumsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array of albums with user preferences' do
      album = create(:album, title: 'OK Computer')
      create(:user_album, user: user, album: album, rating: 5, listened: true)
      get :index, format: :json
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

      get :index, format: :json
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
      get :index, format: :json
      entry = JSON.parse(response.body)['data'].find { |a| a['id'] == album.id }
      expect(entry).not_to have_key('edition_id')
      expect(entry).not_to have_key('edition_name')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single album JSON with album_tracks' do
      album = create(:album, title: 'OK Computer')
      track = create(:track, title: 'Paranoid Android')
      create(:album_track, album: album, track: track, position: 2, disc_number: 1)
      get :show, params: { id: album.id }, format: :json
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
        post :create, params: { album: { title: 'New Album', year: 2020, rating: 4 } }, format: :json
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
      }, format: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['album_tracks'].length).to eq(1)
      at = json['album_tracks'].first
      expect(at['track_id']).to eq(track.id)
      expect(at['edition_id']).to eq(edition.id)
      expect(at['position']).to eq(1)
    end

    it 'returns 422 with invalid params' do
      post :create, params: { album: { title: '' } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    it 'updates album and user preferences' do
      album = create(:album, title: 'Old Title')
      create(:user_album, user: user, album: album)
      patch :update, params: { id: album.id, album: { title: 'New Title', rating: 3, listened: true } }, format: :json
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
      }, format: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      track_ids = json['album_tracks'].map { |at| at['track_id'] }
      expect(track_ids).to contain_exactly(track2.id, track3.id)
      expect(track_ids).not_to include(track1.id)

      updated = json['album_tracks'].find { |at| at['track_id'] == track2.id }
      expect(updated['position']).to eq(1)
    end

    it 'leaves tracks unchanged when album_tracks key is not present' do
      album = create(:album, title: 'OK Computer')
      create(:user_album, user: user, album: album)
      track = create(:track, title: 'Airbag')
      create(:album_track, album: album, track: track, position: 1, disc_number: 1)

      patch :update, params: { id: album.id, album: { title: 'Updated Title' } }, format: :json
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
        delete :destroy, params: { id: album.id }, format: :json
      }.to change(UserAlbum, :count).by(-1).and change(Album, :count).by(0)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'unauthenticated' do
    it 'returns 401 when not logged in' do
      session.delete(:user_id)
      get :index, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
