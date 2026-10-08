# frozen_string_literal: true

require 'rspec'
require 'active_support'
require 'active_support/cache'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/numeric/time'
require 'faraday'

RSpec.describe 'Openapi::SharedParams::RepoChecker' do
  let(:label) { 'https://github.com/oss-compass/compass-web-service' }
  let(:cache_key) { "repo_checker:pr_submitted:#{label}" }
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:indexer) { double('repository indexer', check_exist: false) }
  let(:user) { double('user', login_binds: [double('login bind', nickname: 'contributor')]) }
  let(:connection) { Faraday::Connection.new(label) }
  let(:pull_server) { double('pull server') }
  let(:created_pr) { { status: true, pr_url: 'https://github.com/oss-compass/compass-projects/pull/123' } }

  before do
    stub_const('Openapi', Module.new)
    stub_const('CompassUtils', Module.new { def select_idx_repos_by_lablel_and_level(*); end })
    stub_const('GiteeRepoEnrich', Class.new)
    stub_const('GithubRepoEnrich', Class.new)
    stub_const('GitcodeRepoEnrich', Class.new)
    stub_const('Rails', Class.new { def self.cache; end })
    stub_const('PullServer', Class.new { def execute; end })

    load File.expand_path('../../../app/api/openapi/shared_params/repo_checker.rb', __dir__)
    @checker = Openapi::SharedParams::RepoChecker
    allow(@checker).to receive(:select_idx_repos_by_lablel_and_level)
      .with(label, 'repo', GiteeRepoEnrich, GithubRepoEnrich, GitcodeRepoEnrich)
      .and_return([indexer, [label]])
    allow(Rails).to receive(:cache).and_return(cache)
    allow(Faraday).to receive(:new).with(url: label).and_yield(connection).and_return(connection)
    allow(connection).to receive(:head).and_return(Faraday::Response.new(status: 200))
    allow(PullServer).to receive(:new).and_return(pull_server)
    allow(pull_server).to receive(:execute).and_return(created_pr)
  end

  def check_repository
    @checker.check_repo!(label, 'repo', user)
  end

  it 'removes the pending marker when submission fails' do
    allow(pull_server).to receive(:execute).and_return(status: false, message: 'Upstream unavailable')

    status, message = check_repository

    expect(status).to be(false)
    expect(cache.read(cache_key)).to be_nil
    expect(message).to eq('Upstream unavailable')
  end

  it 'allows a failed submission to be retried before the seven-day expiration' do
    allow(pull_server).to receive(:execute)
      .and_return({ status: false, message: 'Upstream unavailable' }, created_pr)

    check_repository
    _, message = check_repository

    expect(pull_server).to have_received(:execute).twice
    expect(message).to include(created_pr[:pr_url])
    expect(cache.read(cache_key)).to eq(label)
  end

  it 'keeps a pending marker while submission is running and after it succeeds' do
    allow(pull_server).to receive(:execute) do
      expect(cache.read(cache_key)).to eq(label)
      created_pr
    end

    _, message = check_repository
    _, repeated_message = check_repository

    expect(message).to include(created_pr[:pr_url])
    expect(repeated_message).to include('PR 正在处理中')
    expect(pull_server).to have_received(:execute).once
    expect(cache.read(cache_key)).to eq(label)
  end

  it 'does not submit again when a pending marker already exists' do
    cache.write(cache_key, label, expires_in: 7.days)

    _, message = check_repository

    expect(message).to include('PR 正在处理中')
    expect(pull_server).not_to have_received(:execute)
  end

  it 'returns normally for repositories that are already indexed' do
    allow(indexer).to receive(:check_exist).and_return(true)

    expect(check_repository).to eq([true, nil])
    expect(connection).not_to have_received(:head)
    expect(PullServer).not_to have_received(:new)
    expect(cache.read(cache_key)).to be_nil
  end

  it 'does not mark an inaccessible repository as submitted' do
    allow(connection).to receive(:head).and_return(Faraday::Response.new(status: 404))

    _, message = check_repository

    expect(message).to include('项目无法访问')
    expect(PullServer).not_to have_received(:new)
    expect(cache.read(cache_key)).to be_nil
  end
end
