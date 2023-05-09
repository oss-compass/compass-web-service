Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api/graphql"
  end

  with_dev_auth =
    lambda do |app|
    Rack::Builder.new do
      use Rack::Auth::Basic do |username, password|
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(username),
          ::Digest::SHA256.hexdigest(ENV.fetch("ADMIN_WEB_USERNAME"))) &
          ActiveSupport::SecurityUtils.secure_compare(
            ::Digest::SHA256.hexdigest(password),
            ::Digest::SHA256.hexdigest(ENV.fetch("ADMIN_WEB_PASSWORD")))
      end
      run app
    end
  end

  post "/api/graphql", to: "graphql#execute"
  # mount Sidekiq::Web => '/sidekiq'
  mount with_dev_auth.call(Crono::Engine), at: '/crono'

  root to: 'application#website'

  devise_for :users, defaults: { format: :json }, only: :omniauth_callbacks, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  devise_scope :user do
    # If you change these urls and helpers, you must change these files too:
    # - config/initializers/devise.rb#JWT Devise
    # - spec/support/authentication_helper.rb
    post '/users/login' => 'sessions#create', as: :user_session
    delete '/users/logout' => 'sessions#destroy', as: :destroy_user_session
    post '/users/signup' => 'registrations#create', as: :user_registration
    get '/users/auth/:provider/callback' => 'omniauth_callbacks#callback', as: :user_omniauth_callback
  end

  post '/api/workflow', to: 'application#workflow', as: :workflow
  post '/api/hook', to: 'application#hook', as: :hook

  get '/(*path)', to: 'application#website', as: :website
end
