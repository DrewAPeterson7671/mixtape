require 'rails_helper'

RSpec.describe EpochsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it_behaves_like 'PerUserLookup', :epoch, :epoch

  describe 'GET #index' do
    it 'returns 200 and JSON array' do
      create(:epoch, name: 'High School', user: user)
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json).to be_an(Array)
      expect(json.first['name']).to eq('High School')
    end
  end

  describe 'GET #show' do
    it 'returns 200 and single record' do
      epoch = create(:epoch, name: 'College', user: user)
      get :show, params: { id: epoch.id }, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)['data']
      expect(json['name']).to eq('College')
    end
  end

  describe 'POST #create' do
    it 'creates an epoch and returns 201' do
      expect {
        post :create, params: { epoch: { name: 'New Epoch' } }, format: :json
      }.to change(Epoch, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'updates the epoch' do
      epoch = create(:epoch, name: 'Old', user: user)
      patch :update, params: { id: epoch.id, epoch: { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(epoch.reload.name).to eq('New')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the epoch' do
      epoch = create(:epoch, user: user)
      expect {
        delete :destroy, params: { id: epoch.id }, format: :json
      }.to change(Epoch, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET #index ordering' do
    it 'returns records sorted by sequence ASC NULLS LAST, then name ASC' do
      create(:epoch, name: 'Zebra', sequence: nil, user: user)
      create(:epoch, name: 'Alpha', sequence: 2, user: user)
      create(:epoch, name: 'Beta', sequence: 1, user: user)
      create(:epoch, name: 'Apple', sequence: nil, user: user)
      get :index, format: :json
      names = JSON.parse(response.body)['data'].pluck('name')
      expect(names).to eq(%w[Beta Alpha Apple Zebra])
    end
  end

  describe 'sequence column' do
    it 'accepts sequence on create' do
      post :create, params: { epoch: { name: 'Test', sequence: 3 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['sequence']).to eq(3)
    end

    it 'accepts sequence on update' do
      epoch = create(:epoch, name: 'Test', user: user)
      patch :update, params: { id: epoch.id, epoch: { sequence: 5 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(epoch.reload.sequence).to eq(5)
    end
  end

  describe 'definition column' do
    it 'accepts definition on create' do
      post :create, params: { epoch: { name: 'Test', definition: 'A test epoch' } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['definition']).to eq('A test epoch')
    end

    it 'accepts definition on update' do
      epoch = create(:epoch, name: 'Test', user: user)
      patch :update, params: { id: epoch.id, epoch: { definition: 'Updated meaning' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(epoch.reload.definition).to eq('Updated meaning')
    end
  end

  describe 'year_start column' do
    it 'accepts year_start on create' do
      post :create, params: { epoch: { name: 'Test', year_start: 2000 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['year_start']).to eq(2000)
    end

    it 'accepts year_start on update' do
      epoch = create(:epoch, name: 'Test', user: user)
      patch :update, params: { id: epoch.id, epoch: { year_start: 1995 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(epoch.reload.year_start).to eq(1995)
    end
  end

  describe 'year_end column' do
    it 'accepts year_end on create' do
      post :create, params: { epoch: { name: 'Test', year_end: 2005 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['year_end']).to eq(2005)
    end

    it 'accepts year_end on update' do
      epoch = create(:epoch, name: 'Test', user: user)
      patch :update, params: { id: epoch.id, epoch: { year_end: 2010 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(epoch.reload.year_end).to eq(2010)
    end
  end

  describe 'replay column' do
    it 'accepts replay on create' do
      post :create, params: { epoch: { name: 'Test', replay: 10 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['replay']).to eq(10)
    end

    it 'accepts replay on update' do
      epoch = create(:epoch, name: 'Test', user: user)
      patch :update, params: { id: epoch.id, epoch: { replay: 20 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(epoch.reload.replay).to eq(20)
    end
  end

  describe 'weight column' do
    it 'accepts weight on create' do
      post :create, params: { epoch: { name: 'Test', weight: 5 } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['weight']).to eq(5)
    end

    it 'accepts weight on update' do
      epoch = create(:epoch, name: 'Test', user: user)
      patch :update, params: { id: epoch.id, epoch: { weight: 8 } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(epoch.reload.weight).to eq(8)
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
