# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :cognito,

    # OIDC discovery (recommended)
    discovery: true,
    issuer: ENV.fetch("COGNITO_ISSUER"),

    client_options: {
      identifier: ENV.fetch("COGNITO_CLIENT_ID"),
      secret: nil, # public client
      redirect_uri: ENV.fetch("COGNITO_REDIRECT_URI") # e.g. http://localhost:3000/auth/cognito/callback
    },

    # Auth code flow
    response_type: :code,
    scope: %i[openid email profile],

    # PKCE
    pkce: true
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true



class OmniAuthLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO']&.start_with?('/auth/')
      Rails.logger.info "OmniAuth middleware handling: #{env['PATH_INFO']}"
    end
    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before OmniAuth::Builder, OmniAuthLogger

