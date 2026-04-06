require 'rails_helper'

RSpec.describe TracksController, type: :controller do
  let(:user) { create(:user) }
  let(:artist) { create(:artist) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array of tracks with user preferences' do
      track = create(:track, title: 'Creep')
      track.artists << artist
      create(:user_track, user: user, track: track, rating: 3, listened: true)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      entry = json.find { |t| t['id'] == track.id }
      expect(entry['title']).to eq('Creep')
      expect(entry['rating']).to eq(3)
      expect(entry['listened']).to eq(true)
      expect(entry['artist_name']).to be_an(Array)
      expect(entry['artist_ids']).to be_an(Array)
      expect(entry['album_ids']).to be_an(Array)
    end

    it 'sorts by artist name, album title, then track title' do
      beatles = create(:artist, name: 'The Beatles')
      arcade  = create(:artist, name: 'Arcade Fire')
      abbey   = create(:album, title: 'Abbey Road')
      funeral = create(:album, title: 'Funeral')

      # Beatles - Abbey Road tracks
      come = create(:track, title: 'Come Together')
      come.artists << beatles
      come.albums << abbey
      create(:user_track, user: user, track: come)

      something = create(:track, title: 'Something')
      something.artists << beatles
      something.albums << abbey
      create(:user_track, user: user, track: something)

      # Arcade Fire - Funeral track
      wake = create(:track, title: 'Wake Up')
      wake.artists << arcade
      wake.albums << funeral
      create(:user_track, user: user, track: wake)

      get :index, format: :json
      titles = JSON.parse(response.body)['data'].map { |t| t['title'] }
      expect(titles).to eq(['Wake Up', 'Come Together', 'Something'])
    end

    it 'excludes tracks not in user collection' do
      in_collection = create(:track, title: 'In Collection')
      create(:user_track, user: user, track: in_collection)
      create(:track, title: 'Not In Collection')

      get :index, format: :json
      json = JSON.parse(response.body)['data']
      titles = json.map { |t| t['title'] }
      expect(titles).to include('In Collection')
      expect(titles).not_to include('Not In Collection')
    end

    it 'excludes tracks belonging to another user' do
      other_user = create(:user)
      my_track = create(:track, title: 'Mine')
      other_track = create(:track, title: 'Theirs')
      create(:user_track, user: user, track: my_track)
      create(:user_track, user: other_user, track: other_track)

      get :index, format: :json
      json = JSON.parse(response.body)['data']
      titles = json.map { |t| t['title'] }
      expect(titles).to include('Mine')
      expect(titles).not_to include('Theirs')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single track JSON' do
      track = create(:track, title: 'Creep')
      track.artists << artist
      get :show, params: { id: track.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('Creep')
    end
  end

  describe 'POST #create' do
    it 'creates a Track and UserTrack and returns 201' do
      expect {
        post :create, params: { track: { title: 'New Track', artist_ids: [ artist.id ], rating: 2 } }, format: :json
      }.to change(Track, :count).by(1).and change(UserTrack, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('New Track')
      expect(json['rating']).to eq(2)
    end

    it 'creates an AlbumTrack when album_id is provided' do
      album = create(:album)
      expect {
        post :create, params: { track: { title: 'Album Track', artist_ids: [ artist.id ], album_id: album.id, position: 3, disc_number: 1 } }, format: :json
      }.to change(AlbumTrack, :count).by(1)
      expect(response).to have_http_status(:created)
      at = AlbumTrack.last
      expect(at.position).to eq(3)
      expect(at.disc_number).to eq(1)
    end

    it 'creates AlbumTrack records when album_ids is provided' do
      album1 = create(:album)
      album2 = create(:album)
      post :create, params: { track: { title: 'Multi Album Track', artist_ids: [artist.id], album_ids: [album1.id, album2.id] } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['album_ids']).to match_array([album1.id, album2.id])
      track = Track.find(json['id'])
      expect(track.album_tracks.count).to eq(2)
      expect(track.album_tracks.pluck(:position)).to all(be_nil)
    end

    it 'returns 422 with invalid params' do
      post :create, params: { track: { title: '' } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    it 'updates track and user preferences' do
      track = create(:track, title: 'Old Title')
      track.artists << artist
      create(:user_track, user: user, track: track)
      patch :update, params: { id: track.id, track: { title: 'New Title', rating: 5, listened: true } }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('New Title')
      expect(json['rating']).to eq(5)
      expect(json['listened']).to eq(true)
    end

    it 'syncs album associations when album_ids is provided' do
      track = create(:track, title: 'Sync Test')
      track.artists << artist
      create(:user_track, user: user, track: track)
      album_keep = create(:album)
      album_remove = create(:album)
      album_add = create(:album)
      AlbumTrack.create!(album: album_keep, track: track)
      AlbumTrack.create!(album: album_remove, track: track)

      patch :update, params: { id: track.id, track: { album_ids: [album_keep.id, album_add.id] } }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['album_ids']).to match_array([album_keep.id, album_add.id])
      expect(track.reload.album_ids).to match_array([album_keep.id, album_add.id])
    end

    it 'leaves album associations unchanged when album_ids key is absent' do
      track = create(:track, title: 'No Change')
      track.artists << artist
      create(:user_track, user: user, track: track)
      album = create(:album)
      AlbumTrack.create!(album: album, track: track)

      patch :update, params: { id: track.id, track: { title: 'Updated Title' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(track.reload.album_ids).to eq([album.id])
    end
  end

  describe 'DELETE #destroy' do
    it 'removes only the UserTrack, not the Track' do
      track = create(:track)
      track.artists << artist
      create(:user_track, user: user, track: track)
      expect {
        delete :destroy, params: { id: track.id }, format: :json
      }.to change(UserTrack, :count).by(-1).and change(Track, :count).by(0)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not cascade to remove UserArtist records' do
      track = create(:track)
      track.artists << artist
      create(:user_track, user: user, track: track)
      create(:user_artist, user: user, artist: artist)

      expect {
        delete :destroy, params: { id: track.id }, format: :json
      }.to change(UserTrack, :count).by(-1).and change(UserArtist, :count).by(0)
    end
  end

  describe 'record not found' do
    it 'raises RecordNotFound for show with non-existent id' do
      expect {
        get :show, params: { id: -1 }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises RecordNotFound for update with non-existent id' do
      expect {
        patch :update, params: { id: -1, track: { title: 'X' } }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises RecordNotFound for destroy with non-existent id' do
      expect {
        delete :destroy, params: { id: -1 }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
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
