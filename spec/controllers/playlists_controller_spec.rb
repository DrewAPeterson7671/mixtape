require 'rails_helper'

RSpec.describe PlaylistsController, type: :controller do
  let(:user) { create(:user) }
  let(:genre) { create(:genre) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns only current user playlists' do
      own = create(:playlist, user: user, genre: genre)
      other_user = create(:user)
      _other = create(:playlist, user: other_user, genre: genre)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json.map { |p| p['id'] }).to eq([ own.id ])
    end
  end

  describe 'GET #show' do
    it 'returns 200 for own playlist' do
      playlist = create(:playlist, user: user, genre: genre)
      get :show, params: { id: playlist.id }, format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'raises RecordNotFound for another user playlist' do
      other_user = create(:user)
      other_playlist = create(:playlist, user: other_user, genre: genre)
      expect {
        get :show, params: { id: other_playlist.id }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #create' do
    it 'creates a playlist owned by current_user' do
      expect {
        post :create, params: { playlist: { name: 'My Playlist', platform: 'Spotify', genre_id: genre.id, year: 2020 } }, format: :json
      }.to change(Playlist, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('My Playlist')
      expect(Playlist.last.user).to eq(user)
    end

    it 'returns 422 with invalid params' do
      post :create, params: { playlist: { name: '', platform: '' } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    it 'updates own playlist' do
      playlist = create(:playlist, user: user, genre: genre, name: 'Old Name')
      patch :update, params: { id: playlist.id, playlist: { name: 'New Name' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(playlist.reload.name).to eq('New Name')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes own playlist' do
      playlist = create(:playlist, user: user, genre: genre)
      expect {
        delete :destroy, params: { id: playlist.id }, format: :json
      }.to change(Playlist, :count).by(-1)
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
