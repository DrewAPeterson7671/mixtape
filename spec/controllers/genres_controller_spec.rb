require 'rails_helper'

RSpec.describe GenresController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:genre, name: 'Rock')
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Rock')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      genre = create(:genre, name: 'Jazz')
      get :show, params: { id: genre.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('Jazz')
    end
  end

  describe 'POST #create' do
    it 'creates a genre and returns 201' do
      expect {
        post :create, params: { genre: { name: 'Blues' } }, format: :json
      }.to change(Genre, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'updates the genre' do
      genre = create(:genre, name: 'Old')
      patch :update, params: { id: genre.id, genre: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(genre.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the genre' do
      genre = create(:genre)
      expect {
        delete :destroy, params: { id: genre.id }, format: :json
      }.to change(Genre, :count).by(-1)
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
