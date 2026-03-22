class TestAuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login

  before_action :ensure_non_production

  def create
    user = User.find_or_create_by!(email: params[:email]) do |u|
      u.cognito_sub = "test-#{SecureRandom.uuid}"
      u.name = params[:name] || "Test User"
    end

    session[:user_id] = user.id
    render json: { logged_in: true, user: { id: user.id, email: user.email, name: user.name } }
  end

  private

  def ensure_non_production
    head :not_found unless Rails.env.development? || Rails.env.test?
  end
end
