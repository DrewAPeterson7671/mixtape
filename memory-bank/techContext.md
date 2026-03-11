# Tech Context

## Stack Summary

| Component | Version/Tool |
|-----------|-------------|
| Language | Ruby 3.4.2 |
| Framework | Rails 7.2.2 |
| Database | PostgreSQL |
| Web Server | Puma |
| Auth Provider | AWS Cognito (OIDC) |
| Frontend Transport | JSON API over HTTP |

## Key Dependencies

### Authentication
- `omniauth` ~> 2.1 — Authentication framework
- `omniauth_openid_connect` ~> 0.8 — OIDC strategy for Cognito
- `omniauth-rails_csrf_protection` — CSRF protection for OmniAuth
- `omniauth-oauth2` ~> 1.8 — OAuth2 base strategy

### CORS & API
- `rack-cors` — Cross-origin request handling for frontend at localhost:1841
- `jbuilder` — JSON view templates (in Gemfile but orphaned — all controllers render JSON directly via `render json:`. The 32 `.json.jbuilder` files under `app/views/` are unused)

### Frontend/Hotwire (Rails scaffold defaults — not actively used)
- `importmap-rails` — JavaScript ESM import maps
- `turbo-rails` — Hotwire Turbo for SPA-like page loads
- `stimulus-rails` — Hotwire Stimulus for JavaScript sprinkles
- `sprockets-rails` — Asset pipeline

**Note:** These are Rails scaffold defaults still in the Gemfile but not actively used. The frontend is a separate Ext JS application at `localhost:1841`.

### Database
- `pg` — PostgreSQL adapter

### Testing
- `rspec-rails` ~> 7.0 — Test framework
- `factory_bot_rails` — Test data factories
- `faker` — Fake data generation
- `shoulda-matchers` ~> 6.0 — One-liner model/controller matchers
- `capybara` — Browser integration testing
- `selenium-webdriver` — Browser driver for system tests

### Development & CI
- `brakeman` — Static analysis for security vulnerabilities
- `rubocop-rails-omakase` — Rails-standard linting rules
- `dotenv-rails` — Load `.env` into `ENV` in dev/test
- `debug` — Ruby debugger
- `web-console` — In-browser console on error pages
- `bootsnap` — Boot time optimization

## Database Configuration

Defined in `config/database.yml`:

- **Development:** PostgreSQL on port **5433**, database `mixtape_development`, user `mixtape`, password `mixtape_dev`
- **Test:** PostgreSQL on default port, database `mixtape_test`, default `postgres` user with no password
- **Production:** Database `mixtape_production`, credentials from environment variables

The default config block specifies `adapter: postgresql`, `encoding: unicode`, `pool: 5`, `host: localhost`.

## Authentication Infrastructure

### OmniAuth OIDC Configuration (`config/initializers/omniauth.rb`)

```ruby
provider :openid_connect,
  name: :cognito,
  discovery: true,
  issuer: ENV.fetch("COGNITO_ISSUER"),
  client_options: {
    identifier: ENV.fetch("COGNITO_CLIENT_ID"),
    secret: ENV.fetch("COGNITO_CLIENT_SECRET"),
    redirect_uri: "http://localhost:3000/auth/cognito/callback"
  },
  response_type: :code,
  scope: %i[openid email profile]
```

Both GET and POST are allowed for OmniAuth request methods. An `OmniAuthLogger` middleware is inserted before the OmniAuth builder for debugging.

### Session Store (`config/initializers/session_store.rb`)

```ruby
Rails.application.config.session_store :cookie_store,
  key: "_app_session",
  same_site: Rails.env.production? ? :none : :lax,
  secure: Rails.env.production?
```

### Required Environment Variables

These must be set in `.env` (loaded by dotenv-rails):

| Variable | Purpose |
|----------|---------|
| `COGNITO_ISSUER` | Cognito user pool issuer URL |
| `COGNITO_CLIENT_ID` | OAuth client identifier |
| `COGNITO_CLIENT_SECRET` | OAuth client secret |
| `COGNITO_DOMAIN` | Cognito domain for logout URL |
| `COGNITO_LOGOUT_REDIRECT` | Where to redirect after Cognito logout |
| `COGNITO_LOGOUT_PATH` | Path on Cognito domain for logout (default: `/logout`) |
| `POST_LOGIN_URL` | Where to redirect after successful login (default: `/`) |

### Auth Flow

1. User visits `/auth/cognito` → OmniAuth redirects to Cognito hosted UI
2. Cognito authenticates → redirects to `/auth/cognito/callback`
3. `SessionsController#create` receives the OmniAuth auth hash
4. `User.find_or_create_by!(cognito_sub: auth.uid)` ensures the user record exists
5. `session[:user_id] = user.id` stores the session
6. Redirect to `POST_LOGIN_URL`

## CORS Configuration (`config/initializers/cors.rb`)

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:1841'
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization']
  end
end
```

Only `http://localhost:1841` is allowed. All HTTP methods and headers are permitted.

## CI Pipeline (`.github/workflows/ci.yml`)

Triggers on pull requests and pushes to `main`. Four jobs:

| Job | What it does |
|-----|-------------|
| `scan_ruby` | Runs `bin/brakeman --no-pager` for security static analysis |
| `scan_js` | Runs `bin/importmap audit` for JavaScript dependency vulnerabilities |
| `lint` | Runs `bin/rubocop -f github` for code style |
| `test` | Runs `bin/rails db:test:prepare test test:system` |

Known issue: The test job runs `bin/rails test` (Minitest) rather than `bundle exec rspec`. It also installs `sqlite3` in the apt-get step, which is no longer needed since the project uses PostgreSQL.

## Testing Setup

### Framework

RSpec with `spec/rails_helper.rb` as the main config:

- `ActiveRecord::Migration.maintain_test_schema!` — auto-migrates test DB
- `config.use_transactional_fixtures = true` — wraps each test in a transaction
- `config.infer_spec_type_from_file_location!` — auto-detects spec type from directory
- `config.include FactoryBot::Syntax::Methods` — enables `create`, `build`, etc. without `FactoryBot.` prefix
- Shoulda Matchers configured for RSpec + Rails

### Auth Helpers (`spec/support/auth_helpers.rb`)

```ruby
module AuthHelpers
  def sign_in(user)
    session[:user_id] = user.id
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :controller
end
```

Included only in controller specs. Sets the session directly — no Cognito interaction needed in tests.

### Spec Organization

Specs live under `spec/` following Rails conventions:
- `spec/models/` — model validations, associations
- `spec/controllers/` — controller action tests
- `spec/factories/` — FactoryBot factory definitions
- `spec/support/` — shared helpers (currently just `auth_helpers.rb`)
