require 'rails_helper'

RSpec.describe ArtistsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:artist, name: 'Radiohead')
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
  end

  describe 'unauthenticated' do
    it 'returns 401 when not logged in' do
      session.delete(:user_id)
      get :index, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
