# frozen_string_literal: true

require 'rspec'
require 'shellwords'
require 'active_support/all'
require 'faraday'

RSpec.describe 'committed test environment configuration' do
  it 'provides the mandatory values used by the application configuration' do
    proxy_setting = Faraday.ignore_env_proxy
    root = File.expand_path('../..', __dir__)
    environment = File.readlines(File.join(root, '.env.test')).each_with_object({}) do |line, values|
      next unless line.start_with?('export ')

      key, value = Shellwords.split(line.delete_prefix('export ')).fetch(0).split('=', 2)
      values[key] = value
    end

    # Ambient CI or developer credentials must not hide missing example values.
    configuration = Module.new
    configuration.const_set(:ENV, environment)
    concerns = %w[common director compass_utils gitee_application github_application]
    files = concerns.map { |name| "app/controllers/concerns/#{name}.rb" }
    files << 'app/services/tpc_software_metric_server.rb'
    files.each do |file|
      path = File.join(root, file)
      configuration.module_eval(File.read(path), path)
    end

    files += %w[config/initializers/sneakers.rb config/initializers/devise.rb config/routes.rb]
    required_names = files.flat_map do |file|
      File.read(File.join(root, file)).scan(/ENV\.fetch\((['"])([^'"]+)\1\)(?!\s*\{)/).map(&:last)
    end.uniq
    expect(environment.keys).to include(*required_names)

    omniauth = File.readlines(File.join(root, 'config/initializers/omniauth.rb'))
    scope_line = omniauth.find { |line| line.include?("scope: ENV['SLACK_SCOPE']") }
    scope = scope_line.split('scope: ', 2).last.strip.delete_suffix(',')
    expect(configuration.module_eval(scope)).to include(:openid)
  ensure
    Faraday.ignore_env_proxy = proxy_setting
  end
end
