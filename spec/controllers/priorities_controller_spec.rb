require 'rails_helper'

RSpec.describe PrioritiesController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it_behaves_like 'PerUserLookup', :priority, :priority

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:priority, name: 'High', user: user)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('High')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      priority = create(:priority, name: 'Low', user: user)
      get :show, params: { id: priority.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('Low')
    end
  end

  describe 'POST #create' do
    it 'creates a priority and returns 201' do
      expect {
        post :create, params: { priority: { name: 'Medium' } }, format: :json
      }.to change(Priority, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'updates the priority' do
      priority = create(:priority, name: 'Old', user: user)
      patch :update, params: { id: priority.id, priority: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(priority.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the priority' do
      priority = create(:priority, user: user)
      expect {
        delete :destroy, params: { id: priority.id }, format: :json
      }.to change(Priority, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET #index ordering' do
    it 'returns records sorted by sequence ASC NULLS LAST, then name ASC' do
      create(:priority, name: 'Zebra', sequence: nil, user: user)
      create(:priority, name: 'Alpha', sequence: 2, user: user)
      create(:priority, name: 'Beta', sequence: 1, user: user)
      create(:priority, name: 'Apple', sequence: nil, user: user)
      get :index, format: :json
      names = JSON.parse(response.body)['data'].pluck('name')
      expect(names).to eq(%w[Beta Alpha Apple Zebra])
    end
  end

  describe 'sequence column' do
    it 'accepts sequence on create' do
      post :create, params: { priority: { name: 'Test', sequence: 3 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['sequence']).to eq(3)
    end

    it 'accepts sequence on update' do
      priority = create(:priority, name: 'Test', user: user)
      patch :update, params: { id: priority.id, priority: { sequence: 5 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(priority.reload.sequence).to eq(5)
    end
  end

  describe 'definition column' do
    it 'accepts definition on create' do
      post :create, params: { priority: { name: 'Test', definition: 'A test priority' } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['definition']).to eq('A test priority')
    end

    it 'accepts definition on update' do
      priority = create(:priority, name: 'Test', user: user)
      patch :update, params: { id: priority.id, priority: { definition: 'Updated meaning' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(priority.reload.definition).to eq('Updated meaning')
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
