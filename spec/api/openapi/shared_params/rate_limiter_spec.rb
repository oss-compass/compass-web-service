# frozen_string_literal: true

require 'spec_helper'
require 'grape'
require 'faraday'
require 'active_support/cache'
require 'logger'
require 'stringio'
require_relative '../../../../app/api/openapi/shared_params/rate_limiter'
require_relative '../../../../app/api/openapi/shared_params/error_helpers'

RSpec.describe Openapi::SharedParams::RateLimiter do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:user) { double('user', role_level: 1) }
  let(:app) do
    Class.new(Grape::API) do
      format :json
      helpers Openapi::SharedParams::ErrorHelpers
      rescue_from :all do |error|
        handle_generic_error(error)
      end
      before do
        Openapi::SharedParams::RateLimiter.check_token!(params[:access_token], limit: 1)
      end
      get(:status) { { ok: true } }
    end
  end

  before do
    stub_const('Rails', double('Rails', cache: cache, logger: Logger.new(StringIO.new)))
    stub_const('User', Class.new do
      def self.find_by(**attributes); end
    end)
    allow(User).to receive(:find_by).with(id: 42).and_return(user)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('REMOTE_VERIFY_URL').and_return('https://example.invalid/verify')
    allow(described_class).to receive(:sleep)
  end

  def response(status, body)
    instance_double(Faraday::Response, status: status, body: body)
  end

  def request
    Rack::MockRequest.new(app).get('/status?access_token=test-token')
  end

  def valid_response(type: 1)
    response(201, { valid: true, user_id: 42, type: type }.to_json)
  end

  it 'returns 401 when the verification service rejects the token' do
    allow(Faraday).to receive(:post).and_return(response(401, '{"valid":false}'))

    result = request

    expect(result.status).to eq(401)
    expect(JSON.parse(result.body)['error']).to include('无效或过期的token')
    expect(Faraday).to have_received(:post).once
    expect(User).not_to have_received(:find_by)
  end

  it 'returns 401 for a malformed verification response' do
    allow(Faraday).to receive(:post).and_return(response(201, 'not json'))
    expect(request.status).to eq(401)
  end

  [Faraday::ConnectionFailed, Faraday::TimeoutError].each do |error_class|
    it "returns 503 after exhausting retries for #{error_class}" do
      allow(Faraday).to receive(:post).and_raise(error_class.new('unavailable'))

      result = request

      expect(result.status).to eq(503)
      expect(JSON.parse(result.body)['error']).to include('token 校验失败')
      expect(Faraday).to have_received(:post).exactly(3).times
      expect(described_class).to have_received(:sleep).with(1).twice
    end
  end

  it 'recovers from a transient verification error' do
    calls = 0
    allow(Faraday).to receive(:post) do
      calls += 1
      raise Faraday::ConnectionFailed, 'unavailable' if calls == 1
      valid_response
    end
    expect(request.status).to eq(200)
    expect(calls).to eq(2)
  end

  it 'keeps enforcing the request limit for valid tokens' do
    allow(Faraday).to receive(:post).and_return(valid_response)
    expect(request.status).to eq(200)
    expect(request.status).to eq(429)
  end

  it 'keeps unlimited tokens exempt from the request limit' do
    allow(Faraday).to receive(:post).and_return(valid_response(type: 0))
    2.times { expect(request.status).to eq(200) }
  end
end
