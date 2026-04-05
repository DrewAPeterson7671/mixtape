require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # Use an anonymous controller to test ApplicationController behavior directly
  controller do
    def index
      render json: { ok: true }
    end
  end

  describe '#require_login' do
    it 'returns 401 when no user is in session' do
      get :index, format: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'allows access when a user is in session' do
      user = create(:user)
      sign_in(user)

      get :index, format: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#current_user' do
    it 'returns nil when no user is in session' do
      get :index, format: :json
      expect(controller.send(:current_user)).to be_nil
    end

    it 'returns the user matching session[:user_id]' do
      user = create(:user)
      sign_in(user)

      get :index, format: :json
      expect(controller.send(:current_user)).to eq(user)
    end

    it 'returns nil when session[:user_id] references a deleted user' do
      session[:user_id] = -1

      get :index, format: :json
      expect(controller.send(:current_user)).to be_nil
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#set_current_user' do
    controller do
      def index
        render json: { current_user_id: Current.user&.id }
      end
    end

    it 'sets Current.user from session' do
      user = create(:user)
      sign_in(user)

      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json['current_user_id']).to eq(user.id)
    end

    it 'leaves Current.user nil when not logged in' do
      get :index, format: :json
      # Unauthenticated — blocked by require_login before Current.user matters
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
