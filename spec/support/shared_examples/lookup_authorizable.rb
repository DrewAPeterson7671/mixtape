RSpec.shared_examples 'PerUserLookup' do |factory_name, param_key|
  let(:other_user) { create(:user) }

  describe 'per-user ownership - index' do
    it 'returns only current user records' do
      own_record = create(factory_name, name: 'Own Rec', user: user)
      create(factory_name, name: 'Other Rec', user: other_user)

      get :index, format: :json
      names = JSON.parse(response.body)['data'].map { |r| r['name'] }
      expect(names).to include('Own Rec')
      expect(names).not_to include('Other Rec')
    end
  end

  describe 'per-user ownership - show' do
    it 'shows own record' do
      record = create(factory_name, name: 'Own Show', user: user)
      get :show, params: { id: record.id }, format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 for other user record' do
      record = create(factory_name, name: 'Other Show', user: other_user)
      expect {
        get :show, params: { id: record.id }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'per-user ownership - create' do
    it 'assigns user_id to current user' do
      post :create, params: { param_key => { name: 'Created' } }, format: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)['data']
      expect(json['user_id']).to eq(user.id)
    end

    it 'rejects duplicates against own records' do
      create(factory_name, name: 'Mine', user: user)
      post :create, params: { param_key => { name: 'Mine' } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'per-user ownership - update' do
    it 'updates own record' do
      record = create(factory_name, name: 'Old', user: user)
      patch :update, params: { id: record.id, param_key => { name: 'New' } }, format: :json
      expect(response).to have_http_status(:ok)
      expect(record.reload.name).to eq('New')
    end

    it 'returns 404 for other user record' do
      record = create(factory_name, name: 'Other', user: other_user)
      expect {
        patch :update, params: { id: record.id, param_key => { name: 'Hacked' } }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'per-user ownership - destroy' do
    it 'deletes own record' do
      record = create(factory_name, name: 'Delete Me', user: user)
      expect {
        delete :destroy, params: { id: record.id }, format: :json
      }.to change(record.class, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 for other user record' do
      record = create(factory_name, name: 'Other Del', user: other_user)
      expect {
        delete :destroy, params: { id: record.id }, format: :json
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
