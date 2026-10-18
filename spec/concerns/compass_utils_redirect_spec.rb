# frozen_string_literal: true

require 'spec_helper'
require 'addressable/uri'
require 'active_support/core_ext/object/blank'

RSpec.describe 'CompassUtils#redirect_url' do
  before do
    stub_const('Director', Module.new)
    stub_const('CompassUtils', Module.new)
    load File.expand_path('../../app/controllers/concerns/compass_utils.rb', __dir__)
    allow(ENV).to receive(:[]).and_call_original
  end

  let(:utils) do
    Class.new do
      include CompassUtils
      attr_accessor :cookies
    end.new.tap { |instance| instance.cookies = {} }
  end

  it 'keeps the configured frontend port for a relative fallback' do
    allow(ENV).to receive(:[]).with('DEFAULT_HOST').and_return('http://localhost:3000')
    expect(utils.redirect_url(default_url: '/auth/signin')).to eq('http://localhost:3000/auth/signin')
  end

  it 'replaces a stale callback port with the configured port' do
    allow(ENV).to receive(:[]).with('DEFAULT_HOST').and_return('https://compass.example:8443')
    utils.cookies['auth.callback-url'] = 'http://old.example:3000/lab/model/my?tab=public#models'
    expect(utils.redirect_url).to eq('https://compass.example:8443/lab/model/my?tab=public#models')
  end

  it 'clears a callback port when the frontend uses the default HTTPS port' do
    allow(ENV).to receive(:[]).with('DEFAULT_HOST').and_return('https://compass.example')
    utils.cookies['auth.callback-url'] = 'http://old.example:3000/lab/model/my'
    expect(utils.redirect_url).to eq('https://compass.example/lab/model/my')
  end

  it 'still ignores callback cookies when requested' do
    allow(ENV).to receive(:[]).with('DEFAULT_HOST').and_return('https://compass.example')
    utils.cookies['auth.callback-url'] = 'http://old.example:3000/old'
    expect(utils.redirect_url(default_url: '/auth/signin', skip_cookies: true)).to eq('https://compass.example/auth/signin')
  end
end
