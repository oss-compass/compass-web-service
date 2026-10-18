# frozen_string_literal: true

require 'spec_helper'
require 'addressable/uri'

RSpec.describe 'CompassUtils repository source selection' do
  before do
    stub_const('Director', Module.new do
      def director_repo_list(_url); end
    end)
    stub_const('CompassUtils', Module.new)
    load File.expand_path('../../app/controllers/concerns/compass_utils.rb', __dir__)
  end

  let(:utils) { Class.new { include CompassUtils }.new }

  it 'uses the host rather than a provider name in the repository path' do
    url = 'https://github.com/example/gitee.com'
    expect(utils.extract_repos_source(url, 'repo')).to eq('github')
  end

  it 'uses the URL host when selecting the index' do
    url = 'https://github.com/example/gitee.com'
    expect(utils.select_idx_repos_by_lablel_and_level(url, 'repo', :gitee, :github, :gitcode))
      .to eq([:github, [url], 'github'])
  end

  it 'recognizes case-insensitive hosts' do
    expect(utils.extract_repos_source('https://GITCODE.COM/owner/repo', 'repo')).to eq('gitcode')
  end

  it 'does not classify unknown hosts by their paths' do
    expect(utils.extract_repos_source('https://example.com/github.com/repo', 'repo')).to eq('combine')
  end

  it 'ignores missing and malformed repository URLs' do
    expect(utils.extract_repos_source(nil, 'repo')).to eq('combine')
    expect(utils.extract_repos_source('https://[bad', 'repo')).to eq('combine')
  end

  it 'keeps the explicit GitCode index and its legacy fallback' do
    url = 'https://gitcode.com/owner/repo'
    expect(utils.select_idx_repos_by_lablel_and_level(url, 'repo', :gitee, :github, :gitcode))
      .to eq([:gitcode, [url], 'gitcode'])
    expect(utils.select_idx_repos_by_lablel_and_level(url, 'repo', :gitee, :github))
      .to eq([:github, [url], 'gitcode'])
  end

  it 'retains community majority and tie behavior' do
    stub_const('ProjectTask', Class.new do
      def self.find_by(**_args); end
    end)
    allow(ProjectTask).to receive(:find_by).and_return(nil)
    allow(utils).to receive(:director_repo_list).with(nil).and_return([
      'https://github.com/one/gitee.com', 'https://github.com/two/repo', 'https://gitee.com/three/repo'
    ])
    expect(utils.extract_repos_source('community', 'community')).to eq('github')
    allow(utils).to receive(:director_repo_list).with(nil).and_return([
      'https://github.com/one/repo', 'https://gitee.com/two/repo'
    ])
    expect(utils.extract_repos_source('community', 'community')).to eq('combine')
  end
end
