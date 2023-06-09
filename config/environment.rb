# Load the Rails application.
require 'opentelemetry/sdk'
require_relative "application"

OpenTelemetry::SDK.configure do |c|
  c.use_all
end

# Initialize the Rails application.
Rails.application.initialize!
