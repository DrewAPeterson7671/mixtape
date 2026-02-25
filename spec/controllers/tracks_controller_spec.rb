require 'rails_helper'

RSpec.describe TracksController, type: :controller do
  let(:user) { create(:user) }
  let(:artist) { create(:artist) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array of tracks with user preferences' do
      track = create(:track, title: 'Creep', artist: artist)
      create(:user_track, user: user, track: track, rating: 3, listened: true)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      entry = json.find { |t| t['id'] == track.id }
      expect(entry['title']).to eq('Creep')
      expect(entry['rating']).to eq(3)
      expect(entry['listened']).to eq(true)
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single track JSON' do
      track = create(:track, title: 'Creep', artist: artist)
      get :show, params: { id: track.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('Creep')
    end
  end

  describe 'POST #create' do
    it 'creates a Track and UserTrack and returns 201' do
      expect {
        post :create, params: { track: { title: 'New Track', artist_id: artist.id, rating: 2 } }, format: :json
      }.to change(Track, :count).by(1).and change(UserTrack, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('New Track')
      expect(json['rating']).to eq(2)
    end

    it 'returns 422 with invalid params' do
      post :create, params: { track: { title: '' } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    it 'updates track and user preferences' do
      track = create(:track, title: 'Old Title', artist: artist)
      create(:user_track, user: user, track: track)
      patch :update, params: { id: track.id, track: { title: 'New Title', rating: 5, listened: true } }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['title']).to eq('New Title')
      expect(json['rating']).to eq(5)
      expect(json['listened']).to eq(true)
    end
  end

  describe 'DELETE #destroy' do
    it 'removes only the UserTrack, not the Track' do
      track = create(:track, artist: artist)
      create(:user_track, user: user, track: track)
      expect {
        delete :destroy, params: { id: track.id }, format: :json
      }.to change(UserTrack, :count).by(-1).and change(Track, :count).by(0)
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
