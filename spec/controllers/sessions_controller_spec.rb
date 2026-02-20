require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #status' do
    context 'when logged in' do
      it 'returns logged_in true with user info' do
        user = create(:user, name: 'Alice', email: 'alice@example.com')
        session[:user_id] = user.id
        get :status, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['logged_in']).to eq(true)
        expect(json['user']['name']).to eq('Alice')
        expect(json['user']['email']).to eq('alice@example.com')
      end
    end

    context 'when not logged in' do
      it 'returns logged_in false' do
        get :status, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['logged_in']).to eq(false)
      end
    end
  end

  describe 'GET #destroy' do
    it 'resets session and redirects to Cognito logout' do
      user = create(:user)
      session[:user_id] = user.id

      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('COGNITO_DOMAIN').and_return('auth.example.com')
      allow(ENV).to receive(:fetch).with('COGNITO_CLIENT_ID').and_return('test-client-id')
      allow(ENV).to receive(:fetch).with('COGNITO_LOGOUT_REDIRECT').and_return('http://localhost:3000')
      allow(ENV).to receive(:fetch).with('COGNITO_LOGOUT_PATH', '/logout').and_return('/logout')

      get :destroy
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include('auth.example.com')
      expect(response.location).to include('test-client-id')
    end
  end

  describe 'GET #failure' do
    it 'returns 401 with error message' do
      user = create(:user)
      session[:user_id] = user.id
      get :failure, params: { message: 'invalid_credentials', strategy: 'cognito' }
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include('Authentication failed')
      expect(response.body).to include('cognito')
      expect(response.body).to include('invalid_credentials')
    end
  end
end
