require 'rails_helper'

RSpec.describe MediaController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it_behaves_like 'PerUserLookup', :medium, :medium

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:medium, name: 'Vinyl', user: user)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Vinyl')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      medium = create(:medium, name: 'CD', user: user)
      get :show, params: { id: medium.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
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
      medium = create(:medium, name: 'Old', user: user)
      patch :update, params: { id: medium.id, medium: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(medium.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the medium' do
      medium = create(:medium, user: user)
      expect {
        delete :destroy, params: { id: medium.id }, format: :json
      }.to change(Medium, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET #index ordering' do
    it 'returns records sorted by sequence ASC NULLS LAST, then name ASC' do
      create(:medium, name: 'Zebra', sequence: nil, user: user)
      create(:medium, name: 'Alpha', sequence: 2, user: user)
      create(:medium, name: 'Beta', sequence: 1, user: user)
      create(:medium, name: 'Apple', sequence: nil, user: user)
      get :index, format: :json
      names = JSON.parse(response.body)['data'].pluck('name')
      expect(names).to eq(%w[Beta Alpha Apple Zebra])
    end
  end

  describe 'sequence column' do
    it 'accepts sequence on create' do
      post :create, params: { medium: { name: 'Test', sequence: 3 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['sequence']).to eq(3)
    end

    it 'accepts sequence on update' do
      medium = create(:medium, name: 'Test', user: user)
      patch :update, params: { id: medium.id, medium: { sequence: 5 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(medium.reload.sequence).to eq(5)
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
