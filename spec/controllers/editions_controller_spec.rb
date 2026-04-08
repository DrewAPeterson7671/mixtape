require 'rails_helper'

RSpec.describe EditionsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it_behaves_like 'PerUserLookup', :edition, :edition

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:edition, name: 'Deluxe', user: user)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Deluxe')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      edition = create(:edition, name: 'Standard', user: user)
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
      edition = create(:edition, name: 'Old', user: user)
      patch :update, params: { id: edition.id, edition: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(edition.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the edition' do
      edition = create(:edition, user: user)
      expect {
        delete :destroy, params: { id: edition.id }, format: :json
      }.to change(Edition, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET #index ordering' do
    it 'returns records sorted by sequence ASC NULLS LAST, then name ASC' do
      create(:edition, name: 'Zebra', sequence: nil, user: user)
      create(:edition, name: 'Alpha', sequence: 2, user: user)
      create(:edition, name: 'Beta', sequence: 1, user: user)
      create(:edition, name: 'Apple', sequence: nil, user: user)
      get :index, format: :json
      names = JSON.parse(response.body)['data'].pluck('name')
      expect(names).to eq(%w[Beta Alpha Apple Zebra])
    end
  end

  describe 'sequence column' do
    it 'accepts sequence on create' do
      post :create, params: { edition: { name: 'Test', sequence: 3 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['sequence']).to eq(3)
    end

    it 'accepts sequence on update' do
      edition = create(:edition, name: 'Test', user: user)
      patch :update, params: { id: edition.id, edition: { sequence: 5 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(edition.reload.sequence).to eq(5)
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
