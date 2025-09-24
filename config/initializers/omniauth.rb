Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :cognito,
    scope: %i[openid email profile],
    response_type: :code,
    discovery: true,
    issuer: ENV.fetch('COGNITO_ISSUER'), # e.g. https://cognito-idp.us-west-2.amazonaws.com/us-west-2_ABC123
    client_options: {
      identifier: ENV.fetch('COGNITO_CLIENT_ID'),
      redirect_uri: ENV.fetch('COGNITO_REDIRECT_URI') # e.g. https://app.example.com/auth/cognito/callback
    },
    pkce: true
end
