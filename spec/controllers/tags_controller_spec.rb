require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:tag, name: 'Favorite')
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('Favorite')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      tag = create(:tag, name: 'Classic')
      get :show, params: { id: tag.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('Classic')
    end
  end

  describe 'POST #create' do
    it 'creates a tag and returns 201' do
      expect {
        post :create, params: { tag: { name: 'New Tag' } }, format: :json
      }.to change(Tag, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'updates the tag' do
      tag = create(:tag, name: 'Old')
      patch :update, params: { id: tag.id, tag: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(tag.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the tag' do
      tag = create(:tag)
      expect {
        delete :destroy, params: { id: tag.id }, format: :json
      }.to change(Tag, :count).by(-1)
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
