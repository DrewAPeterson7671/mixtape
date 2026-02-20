require 'rails_helper'

RSpec.describe PhasesController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:phase, name: 'Discovery')
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Discovery')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      phase = create(:phase, name: 'Exploration')
      get :show, params: { id: phase.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
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
      phase = create(:phase, name: 'Old')
      patch :update, params: { id: phase.id, phase: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(phase.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the phase' do
      phase = create(:phase)
      expect {
        delete :destroy, params: { id: phase.id }, format: :json
      }.to change(Phase, :count).by(-1)
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
