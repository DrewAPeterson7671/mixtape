require 'rails_helper'

RSpec.describe ReleaseTypesController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it_behaves_like 'PerUserLookup', :release_type, :release_type

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:release_type, name: 'LP', user: user)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('LP')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      release_type = create(:release_type, name: 'EP', user: user)
      get :show, params: { id: release_type.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('EP')
    end
  end

  describe 'POST #create' do
    it 'creates a release type and returns 201' do
      expect {
        post :create, params: { release_type: { name: 'Single' } }, format: :json
      }.to change(ReleaseType, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'updates the release type' do
      release_type = create(:release_type, name: 'Old', user: user)
      patch :update, params: { id: release_type.id, release_type: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(release_type.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the release type' do
      release_type = create(:release_type, user: user)
      expect {
        delete :destroy, params: { id: release_type.id }, format: :json
      }.to change(ReleaseType, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET #index ordering' do
    it 'returns records sorted by sequence ASC NULLS LAST, then name ASC' do
      create(:release_type, name: 'Zebra', sequence: nil, user: user)
      create(:release_type, name: 'Alpha', sequence: 2, user: user)
      create(:release_type, name: 'Beta', sequence: 1, user: user)
      create(:release_type, name: 'Apple', sequence: nil, user: user)
      get :index, format: :json
      names = JSON.parse(response.body)['data'].pluck('name')
      expect(names).to eq(%w[Beta Alpha Apple Zebra])
    end
  end

  describe 'sequence column' do
    it 'accepts sequence on create' do
      post :create, params: { release_type: { name: 'Test', sequence: 3 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['sequence']).to eq(3)
    end

    it 'accepts sequence on update' do
      release_type = create(:release_type, name: 'Test', user: user)
      patch :update, params: { id: release_type.id, release_type: { sequence: 5 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(release_type.reload.sequence).to eq(5)
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
