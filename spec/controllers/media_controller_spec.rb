require 'rails_helper'

RSpec.describe MediaController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:medium, name: 'Vinyl')
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Vinyl')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      medium = create(:medium, name: 'CD')
      get :show, params: { id: medium.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('CD')
    end
  end

  describe 'POST #create' do
    it 'creates a medium and returns 201' do
      expect {
        post :create, params: { medium: { name: 'Cassette' } }, format: :json
      }.to change(Medium, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'updates the medium' do
      medium = create(:medium, name: 'Old')
      patch :update, params: { id: medium.id, medium: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(medium.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the medium' do
      medium = create(:medium)
      expect {
        delete :destroy, params: { id: medium.id }, format: :json
      }.to change(Medium, :count).by(-1)
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
