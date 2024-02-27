source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
git_source(:gitee) { |repo| "https://gitee.com/#{repo}.git" }

ruby File.read('.ruby-version')

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.3'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use mariadb as the database for Active Record
gem 'mysql2'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis'

gem 'redis-rails'

# Provides a low-level time-based throttle.
gem 'prorate'

# Use RabbitMQ
gem 'bunny'
gem 'sneakers'

# Use Grape
gem 'grape'
gem 'grape-swagger'

# Use Kafka (only for Content Review)
gem 'connection_pool'
gem 'waterdrop'

# Use OpenSearch
gem 'search_flip'
gem 'opensearch-ruby'

# Use Http Client
gem 'faraday'
gem 'rest-client'

# Git tools
gem 'git_diff_parser'

# Cron
gem 'crono'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# frontend build tool
# gem 'vite_rails'

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"
gem 'aws-sdk-s3', '~> 1'
gem 'active_storage_base64'

# paginator for Ruby
gem 'pagy'

# Map incoming controller parameters to named scopes in the resources
gem 'has_scope'

# A fast JSON:API serializer for Ruby Objects.
gem 'jsonapi-serializer'
# provides some features to use jsonapi-serializer easier
gem 'jsonapi.rb'
gem 'ransack'

# provides support for Cross-Origin Resource Sharing (CORS)
gem 'rack-cors'

# a flexible authentication solution
gem 'devise'
# a devise extension which uses JWT tokens for user authentication
gem 'devise-jwt'

# https://github.com/omniauth/omniauth
gem 'omniauth'
gem 'omniauth-gitee', gitee: 'oss-compass/omniauth-gitee', branch: 'master'
# https://github.com/omniauth/omniauth-github
gem 'omniauth-github'
# https://github.com/cookpad/omniauth-rails_csrf_protection
gem 'omniauth-rails_csrf_protection'
# https://github.com/omniauth/omniauth_openid_connect
gem 'omniauth_openid_connect'
# https://github.com/nevermin/omniauth-wechat-oauth2
gem 'omniauth-wechat-oauth2'
# https://github.com/slack-ruby/slack-ruby-client
gem 'slack-ruby-client'
# https://github.com/roidrage/redis-session-store
gem 'redis-session-store'
# https://github.com/lanrion/weixin_authorize
gem 'weixin_authorize'
# https://github.com/Eric-Guo/wechat
gem 'wechat'
# http://github.com/resque/redis-namespace
gem 'redis-namespace'
# Linting
gem 'brakeman'
gem 'bundler-audit'
gem 'fasterer'
gem 'license_finder', require: false
gem 'overcommit'

# ENV Variables
gem 'dotenv-rails'

# I18n
gem 'rails-i18n'

gem 'addressable'

# OpenTelemetry
gem 'opentelemetry-sdk'
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-instrumentation-all'

# Utils
gem 'nanoid'
gem "lograge"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'annotate'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
  gem 'rspec-rails', '~> 5.0.0'
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'active_record_doctor'

  gem 'bullet'

  gem "rack-reverse-proxy", require: "rack/reverse_proxy"

  gem 'grape_on_rails_routes'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'faker'
  # RSpec matchers for JSON API.
  gem 'jsonapi-rspec'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webdrivers'
end

gem "graphql", "~> 2.0"
gem 'graphql-batch'
gem "graphiql-rails", group: :development

gem "pundit", "~> 2.3"
