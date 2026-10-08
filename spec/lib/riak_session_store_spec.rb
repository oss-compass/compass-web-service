# frozen_string_literal: true

# Exercise the real Rails/Rack store without booting the application or a database.
require 'json'
require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/numeric/time'
require 'action_dispatch'
require 'action_dispatch/middleware/session/abstract_store'
require 'action_dispatch/middleware/stack'
require_relative '../../lib/riak_session_store'

RSpec.describe RiakSessionStore do
  let(:app) { ->(_env) { [200, { 'content-type' => 'text/plain' }, ['ok']] } }
  let(:client) { instance_double(Riak::Client) }
  let(:bucket_type) { instance_double(Riak::BucketType) }
  let(:bucket) { instance_double(Riak::BucketTyped::Bucket) }

  before do
    allow(Riak::Client).to receive(:new).and_return(client)
    allow(client).to receive(:bucket_type).and_return(bucket_type)
    allow(bucket_type).to receive(:bucket).and_return(bucket)
  end

  def build_store(options = nil, middleware: false, **session_options)
    options ||= session_options
    if middleware
      ActionDispatch::MiddlewareStack::Middleware.new(described_class, [options], nil).build(app)
    else
      described_class.new(app, options)
    end
  end

  def expect_selection(store, type, name, type_count: 1, bucket_count: 1)
    expect(client).to have_received(:bucket_type).with(type).exactly(type_count).times
    expect(bucket_type).to have_received(:bucket).with(name).exactly(bucket_count).times
    expect(store.send(:bucket)).to equal(bucket)
    expect(store).to be_a(ActionDispatch::Session::AbstractSecureStore)
    expect(store).to be_a(Rack::Session::Abstract::PersistedSecure)
  end

  it 'selects both documented nested selectors through the real middleware builder' do
    store = build_store({ key: 'tenant_session', riak: {
      client: client, bucket: 'tenant_sessions', bucket_type: 'tenant_type'
    } }, middleware: true)

    expect_selection(store, 'tenant_type', 'tenant_sessions')
    expect(Riak::Client).not_to have_received(:new)
    expect(store.instance_variable_get(:@key)).to eq('tenant_session')
  end

  it 'uses the default bucket type when only the nested bucket is configured' do
    store = build_store(riak: { client: client, bucket: 'tenant_sessions' })
    expect_selection(store, 'default', 'tenant_sessions')
  end

  it 'uses the default bucket when only the nested bucket type is configured' do
    store = build_store(riak: { client: client, bucket_type: 'tenant_type' })
    expect_selection(store, 'tenant_type', 'sessions')
  end

  it 'keeps both defaults when the riak hash is omitted' do
    store = build_store({})
    expect_selection(store, 'default', 'sessions')
    expect(Riak::Client).to have_received(:new).with({})
  end

  it 'keeps both defaults for an empty riak hash' do
    store = build_store(riak: {})
    expect_selection(store, 'default', 'sessions')
    expect(Riak::Client).to have_received(:new).with({})
  end

  it 'preserves the production-shaped defaults, client options and session settings' do
    store = build_store(key: 'session', serializer: :json, riak: {
      expire_after: 1.day, host: 'localhost', pb_port: 8087,
      key_prefix: 'example.org:session:'
    })

    expect_selection(store, 'default', 'sessions')
    expect(Riak::Client).to have_received(:new).with(host: 'localhost', pb_port: 8087)
    expect(store.send(:default_options)).to include(
      expire_after: 1.day, key_prefix: 'example.org:session:', namespace: 'rack:session'
    )
    expect(store.send(:serializer)).to eq(described_class::JsonSerializer)
    expect(store.instance_variable_get(:@key)).to eq('session')
  end

  it 'preserves legacy explicit top-level selectors' do
    store = build_store(bucket: 'legacy_sessions', bucket_type: 'legacy_type',
                        riak: { client: client })
    expect_selection(store, 'legacy_type', 'legacy_sessions')
  end

  it 'filters store-only nested options before constructing the client' do
    build_store(riak: {
      host: 'localhost', pb_port: 8087, bucket: 'tenant_sessions',
      bucket_type: 'tenant_type', expire_after: 120.minutes, key_prefix: 'tenant:'
    })

    expect(Riak::Client).to have_received(:new).with(host: 'localhost', pb_port: 8087)
  end

  it 'gives each explicit top-level selector priority over its nested counterpart' do
    store = build_store(bucket: 'legacy_sessions', bucket_type: 'legacy_type', riak: {
      client: client, bucket: 'tenant_sessions', bucket_type: 'tenant_type'
    })
    expect_selection(store, 'legacy_type', 'legacy_sessions')

    store = build_store(bucket: 'legacy_sessions', riak: {
      client: client, bucket: 'tenant_sessions', bucket_type: 'tenant_type'
    })
    expect_selection(store, 'tenant_type', 'legacy_sessions', bucket_count: 2)

    store = build_store(bucket_type: 'legacy_type', riak: {
      client: client, bucket: 'tenant_sessions', bucket_type: 'tenant_type'
    })
    expect_selection(store, 'legacy_type', 'tenant_sessions', type_count: 2)
  end
end
