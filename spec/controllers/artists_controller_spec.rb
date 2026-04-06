require 'rails_helper'

RSpec.describe ArtistsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      artist = create(:artist, name: 'Radiohead')
      create(:user_artist, user: user, artist: artist)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Radiohead')
    end

    it 'merges user preferences into response' do
      artist = create(:artist)
      create(:user_artist, user: user, artist: artist, rating: 4, complete: true)
      get :index, format: :json
      json = JSON.parse(response.body)['data']
      entry = json.find { |a| a['id'] == artist.id }
      expect(entry['rating']).to eq(4)
      expect(entry['complete']).to eq(true)
    end

    it 'excludes artists not in user collection' do
      in_collection = create(:artist, name: 'In Collection')
      create(:user_artist, user: user, artist: in_collection)
      create(:artist, name: 'Not In Collection')

      get :index, format: :json
      json = JSON.parse(response.body)['data']
      names = json.map { |a| a['name'] }
      expect(names).to include('In Collection')
      expect(names).not_to include('Not In Collection')
    end

    it 'sorts by name, stripping leading articles' do
      %w[The\ Beatles Arcade\ Fire A\ Perfect\ Circle Radiohead].each do |name|
        artist = create(:artist, name: name)
        create(:user_artist, user: user, artist: artist)
      end

      get :index, format: :json
      names = JSON.parse(response.body)['data'].map { |a| a['name'] }
      expect(names).to eq(['Arcade Fire', 'The Beatles', 'A Perfect Circle', 'Radiohead'])
    end

    it 'excludes artists belonging to another user' do
      other_user = create(:user)
      my_artist = create(:artist, name: 'Mine')
      other_artist = create(:artist, name: 'Theirs')
      create(:user_artist, user: user, artist: my_artist)
      create(:user_artist, user: other_user, artist: other_artist)

      get :index, format: :json
      json = JSON.parse(response.body)['data']
      names = json.map { |a| a['name'] }
      expect(names).to include('Mine')
      expect(names).not_to include('Theirs')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single artist JSON' do
      artist = create(:artist, name: 'Radiohead')
      get :show, params: { id: artist.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('Radiohead')
    end
  end

  describe 'POST #create' do
    it 'creates an Artist and UserArtist and returns 201' do
      expect {
        post :create, params: { artist: { name: 'New Artist', rating: 3 } }, format: :json
      }.to change(Artist, :count).by(1).and change(UserArtist, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('New Artist')
      expect(json['rating']).to eq(3)
    end

    it 'reuses an existing artist when name matches' do
      existing = create(:artist, name: 'Existing')
      expect {
        post :create, params: { artist: { name: 'Existing', rating: 4 } }, format: :json
      }.to change(Artist, :count).by(0).and change(UserArtist, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['id']).to eq(existing.id)
    end
  end

  describe 'PATCH #update' do
    it 'updates artist and user preferences' do
      artist = create(:artist, name: 'Old Name')
      create(:user_artist, user: user, artist: artist)
      patch :update, params: { id: artist.id, artist: { name: 'New Name', rating: 5 } }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('New Name')
      expect(json['rating']).to eq(5)
    end
  end

  describe 'DELETE #destroy' do
    it 'removes only the UserArtist, not the Artist' do
      artist = create(:artist)
      create(:user_artist, user: user, artist: artist)
      expect {
        delete :destroy, params: { id: artist.id }, format: :json
      }.to change(UserArtist, :count).by(-1).and change(Artist, :count).by(0)
      expect(response).to have_http_status(:no_content)
    end

    it 'cascade removes UserAlbum records for the artist albums' do
      artist = create(:artist)
      album = create(:album)
      artist.albums << album
      create(:user_artist, user: user, artist: artist)
      create(:user_album, user: user, album: album)

      expect {
        delete :destroy, params: { id: artist.id }, format: :json
      }.to change(UserAlbum, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'cascade removes UserTrack records for the artist tracks' do
      artist = create(:artist)
      track = create(:track)
      artist.tracks << track
      create(:user_artist, user: user, artist: artist)
      create(:user_track, user: user, track: track)

      expect {
        delete :destroy, params: { id: artist.id }, format: :json
      }.to change(UserTrack, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'cascade removes both UserAlbum and UserTrack together' do
      artist = create(:artist)
      album = create(:album)
      track = create(:track)
      artist.albums << album
      artist.tracks << track
      create(:user_artist, user: user, artist: artist)
      create(:user_album, user: user, album: album)
      create(:user_track, user: user, track: track)

      expect {
        delete :destroy, params: { id: artist.id }, format: :json
      }.to change(UserArtist, :count).by(-1)
        .and change(UserAlbum, :count).by(-1)
        .and change(UserTrack, :count).by(-1)
    end

    it 'does not affect other users records' do
      other_user = create(:user)
      artist = create(:artist)
      album = create(:album)
      track = create(:track)
      artist.albums << album
      artist.tracks << track
      create(:user_artist, user: user, artist: artist)
      create(:user_album, user: user, album: album)
      create(:user_track, user: user, track: track)
      create(:user_artist, user: other_user, artist: artist)
      create(:user_album, user: other_user, album: album)
      create(:user_track, user: other_user, track: track)

      delete :destroy, params: { id: artist.id }, format: :json

      expect(UserArtist.where(user: other_user, artist: artist)).to exist
      expect(UserAlbum.where(user: other_user, album: album)).to exist
      expect(UserTrack.where(user: other_user, track: track)).to exist
    end

    it 'does not delete catalog records' do
      artist = create(:artist)
      album = create(:album)
      track = create(:track)
      artist.albums << album
      artist.tracks << track
      create(:user_artist, user: user, artist: artist)
      create(:user_album, user: user, album: album)
      create(:user_track, user: user, track: track)

      expect {
        delete :destroy, params: { id: artist.id }, format: :json
      }.to change(Artist, :count).by(0)
        .and change(Album, :count).by(0)
        .and change(Track, :count).by(0)
    end
  end

  describe 'record not found' do
    it 'returns 404 for show with non-existent id' do
      expect {
        get :show, params: { id: -1 }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 404 for update with non-existent id' do
      expect {
        patch :update, params: { id: -1, artist: { name: 'X' } }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 404 for destroy with non-existent id' do
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
