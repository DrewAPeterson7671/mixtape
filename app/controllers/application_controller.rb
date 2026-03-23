class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  helper_method :current_user

  before_action :set_current_user
  before_action :require_login

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def set_current_user
    Current.user ||= current_user
  end

  def require_login
    head :unauthorized unless current_user
  end
end
