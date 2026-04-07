require 'rails_helper'

RSpec.describe PhasesController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it_behaves_like 'PerUserLookup', :phase, :phase

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:phase, name: 'Discovery', user: user)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Discovery')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      phase = create(:phase, name: 'Exploration', user: user)
      get :show, params: { id: phase.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('Exploration')
    end
  end

  describe 'POST #create' do
    it 'creates a phase and returns 201' do
      expect {
        post :create, params: { phase: { name: 'New Phase' } }, format: :json
      }.to change(Phase, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'updates the phase' do
      phase = create(:phase, name: 'Old', user: user)
      patch :update, params: { id: phase.id, phase: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(phase.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the phase' do
      phase = create(:phase, user: user)
      expect {
        delete :destroy, params: { id: phase.id }, format: :json
      }.to change(Phase, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET #index ordering' do
    it 'returns records sorted by sequence ASC NULLS LAST, then name ASC' do
      create(:phase, name: 'Zebra', sequence: nil, user: user)
      create(:phase, name: 'Alpha', sequence: 2, user: user)
      create(:phase, name: 'Beta', sequence: 1, user: user)
      create(:phase, name: 'Apple', sequence: nil, user: user)
      get :index, format: :json
      names = JSON.parse(response.body)['data'].pluck('name')
      expect(names).to eq(%w[Beta Alpha Apple Zebra])
    end
  end

  describe 'sequence column' do
    it 'accepts sequence on create' do
      post :create, params: { phase: { name: 'Test', sequence: 3 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['sequence']).to eq(3)
    end

    it 'accepts sequence on update' do
      phase = create(:phase, name: 'Test', user: user)
      patch :update, params: { id: phase.id, phase: { sequence: 5 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(phase.reload.sequence).to eq(5)
    end
  end

  describe 'definition column' do
    it 'accepts definition on create' do
      post :create, params: { phase: { name: 'Test', definition: 'A test phase' } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['definition']).to eq('A test phase')
    end

    it 'accepts definition on update' do
      phase = create(:phase, name: 'Test', user: user)
      patch :update, params: { id: phase.id, phase: { definition: 'Updated meaning' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(phase.reload.definition).to eq('Updated meaning')
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
