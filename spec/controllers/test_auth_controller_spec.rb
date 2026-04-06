require 'rails_helper'

RSpec.describe TestAuthController, type: :controller do
  describe 'POST #create' do
    it 'creates a new user and sets the session' do
      expect {
        post :create, params: { email: 'new@example.com', name: 'New User' }, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(session[:user_id]).to eq(User.last.id)
    end

    it 'returns logged_in true with user info' do
      post :create, params: { email: 'test@example.com', name: 'Test User' }, as: :json

      json = JSON.parse(response.body)
      expect(json['logged_in']).to eq(true)
      expect(json['user']['email']).to eq('test@example.com')
      expect(json['user']['name']).to eq('Test User')
      expect(json['user']['id']).to be_present
    end

    it 'reuses an existing user with the same email' do
      existing = create(:user, email: 'existing@example.com', name: 'Existing')

      expect {
        post :create, params: { email: 'existing@example.com' }, as: :json
      }.not_to change(User, :count)

      expect(session[:user_id]).to eq(existing.id)
    end

    it 'defaults name to "Test User" when not provided' do
      post :create, params: { email: 'noname@example.com' }, as: :json

      user = User.find_by(email: 'noname@example.com')
      expect(user.name).to eq('Test User')
    end

    it 'assigns a cognito_sub for new users' do
      post :create, params: { email: 'sub@example.com' }, as: :json

      user = User.find_by(email: 'sub@example.com')
      expect(user.cognito_sub).to start_with('test-')
    end
  end

  describe 'environment gating' do
    it 'returns 404 in production' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

      post :create, params: { email: 'prod@example.com' }, as: :json

      expect(response).to have_http_status(:not_found)
      expect(User.find_by(email: 'prod@example.com')).to be_nil
    end
  end
end
