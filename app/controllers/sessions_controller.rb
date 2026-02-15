class SessionsController < ApplicationController
  require "uri"

  skip_before_action :require_login, only: [:create, :oidc_callback, :destroy, :passthru]

  # Callback endpoints are reached via a cross-site redirect; don't require Rails CSRF token.
  skip_forgery_protection only: [:create, :oidc_callback]

  # OmniAuth default callback endpoint:
  # GET /auth/:provider/callback  -> sessions#create
  def create
    handle_omniauth_auth!
  end

  # If you already have routes pointing here, keep it working too.
  def oidc_callback
    handle_omniauth_auth!
  end

  # Changes from ai to deal with logout problem 2-16-26
  # def destroy
  #   reset_session
  #   # Send the browser to Cognito logout endpoint so their hosted-UI session is cleared.
  #   domain    = ENV.fetch('COGNITO_DOMAIN')       # e.g. your-domain.auth.us-west-2.amazoncognito.com
  #   client    = ENV.fetch('COGNITO_CLIENT_ID')
  #   return_to = CGI.escape(ENV.fetch('COGNITO_LOGOUT_REDIRECT')) # must be in "Allowed sign-out URLs"
  #   redirect_to "https://#{domain}/logout?client_id=#{client}&logout_uri=#{return_to}"
  # end

  def destroy
    reset_session

    domain = ENV.fetch("COGNITO_DOMAIN") # e.g. us-west-2xxxx.auth.us-west-2.amazoncognito.com
    client_id = ENV.fetch("COGNITO_CLIENT_ID")
    logout_uri = ENV.fetch("COGNITO_LOGOUT_REDIRECT") # e.g. http://localhost:1841/

    logout_path = ENV.fetch("COGNITO_LOGOUT_PATH", "/logout") # try "/logout" or "/oauth2/logout"

    uri = URI::HTTPS.build(host: domain, path: logout_path)
    uri.query = URI.encode_www_form(
      client_id: client_id,
      logout_uri: logout_uri
    )

    redirect_to uri.to_s, allow_other_host: true
  end


  def passthru
    # This action is just a placeholder for OmniAuth.
    render status: 404, plain: "Not found. Authentication passthru."
  end

  def failure
    message = params[:message] || "unknown_error"
    strategy = params[:strategy] || "unknown_strategy"
    render status: :unauthorized, plain: "Authentication failed: #{strategy} (#{message})"
  end


  private

  def handle_omniauth_auth!
    auth = request.env["omniauth.auth"]
    raise ActionController::BadRequest, "Missing OmniAuth auth hash" if auth.blank?

    # auth.credentials => id_token, token (access), refresh_token, expires_at
    user = User.find_or_create_by!(cognito_sub: auth.uid) do |u|
      u.email = auth.info.email
      u.name  = auth.info.name
    end

    # Store only what you need; keep tokens server-side if you’ll refresh.
    session[:user_id] = user.id

    redirect_to ENV.fetch("POST_LOGIN_URL", "/")
  end
end
