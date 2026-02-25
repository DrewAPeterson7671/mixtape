require 'rails_helper'

RSpec.describe EditionsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:edition, name: 'Deluxe')
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Deluxe')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      edition = create(:edition, name: 'Standard')
      get :show, params: { id: edition.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('Standard')
    end
  end

  describe 'POST #create' do
    it 'creates an edition and returns 201' do
      expect {
        post :create, params: { edition: { name: 'Limited' } }, format: :json
      }.to change(Edition, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'updates the edition' do
      edition = create(:edition, name: 'Old')
      patch :update, params: { id: edition.id, edition: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(edition.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the edition' do
      edition = create(:edition)
      expect {
        delete :destroy, params: { id: edition.id }, format: :json
      }.to change(Edition, :count).by(-1)
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
