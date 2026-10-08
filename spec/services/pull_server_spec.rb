# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PullServer do
  before do
    stub_const('GithubApplication::GITHUB_TOKEN', 'isolated-test-token')
    stub_const('GiteeApplication::GITEE_TOKEN', 'isolated-test-token')
    stub_const('ProjectTask', Class.new do
      def self.find_by(**); end
    end)
    allow(I18n).to receive(:t) { |key, **_options| key }
    [:post, :put, :patch, :delete].each do |method|
      expect(Faraday).not_to receive(method)
    end
    @lookups = []
    @submissions = []
    @fork_by_endpoint = {}
    # Transport doubles only; both production fork validators remain active.
    allow(RestClient::Request).to receive(:new) do |options|
      raise 'Unexpected HTTP method' unless options[:method] == :get
      endpoint = options.fetch(:url)
      @lookups << endpoint
      fork = @fork_by_endpoint.fetch(endpoint)
      response = double('GitHub response', body: JSON.dump(fork: fork))
      double('GitHub request', execute: response)
    end
    allow(Faraday).to receive(:get) do |endpoint, *_args|
      @lookups << endpoint
      fork = @fork_by_endpoint.fetch(endpoint)
      double('Gitee response', body: JSON.dump(fork: fork))
    end
  end

  def repository(provider, number, git_suffix: false)
    url = "https://#{provider}.com/contract/repo#{number}"
    url += '.git' if git_suffix
    endpoint = if provider == 'github'
                 "https://api.github.com/repos/contract/repo#{number}"
               else
                 "https://gitee.com/api/v5/repos/contract/repo#{number}?access_token=isolated-test-token"
               end
    [url, endpoint]
  end

  def service(urls, origin)
    server = described_class.new(level: 'repo', project_urls: urls,
                                 extra: { username: 'contract-user', origin: origin })
    expect(server.method(:github_is_fork_repo).owner).to eq(GithubApplication)
    expect(server.method(:gitee_is_fork_repo).owner).to eq(GiteeApplication)
    [:create_github_pull, :create_gitee_pull,
     :create_github_pull_with_multiple_files, :create_gitee_pull_with_multiple_files].each do |name|
      allow(server).to receive(name) do |*args|
        @submissions << [name, args]
        { status: true, pr_url: 'https://example.invalid/test-only' }
      end
    end
    server
  end

  ['github', 'gitee'].each do |provider|
    [2, 5].each do |count|
      it "checks all #{count} #{provider} URLs before preparing a batch" do
        fixtures = (1..count).map { |n| repository(provider, n, git_suffix: n == count) }
        fixtures.each { |_url, endpoint| @fork_by_endpoint[endpoint] = false }
        urls = fixtures.map(&:first)
        result = service(urls, provider).execute
        expect(result[:status]).to eq(true)
        expect(@lookups).to eq(fixtures.map(&:last))
        expect(@submissions.length).to eq(1)
        method_name, args = @submissions.first
        expect(method_name).to eq("create_#{provider}_pull_with_multiple_files".to_sym)
        pairs = args[1]
        expect(pairs.length).to eq(count)
        fixtures.each_with_index do |(url, _endpoint), i|
          content = YAML.safe_load(Base64.strict_decode64(pairs.fetch("single-repositories/#{provider}/contract/repo#{i + 1}.yml")))
          expect(content.fetch('resource_types').fetch('repo_urls')).to eq(url.chomp('.git'))
        end
      end
    end

    it "rejects a fork at the second #{provider} URL before submission" do
      fixtures = (1..3).map { |n| repository(provider, n) }
      fixtures.each_with_index { |(_url, endpoint), i| @fork_by_endpoint[endpoint] = i == 1 }
      result = service(fixtures.map(&:first), provider).execute
      expect(result).to include(status: false, message: 'oauth.validate.fork')
      expect(@lookups).to eq(fixtures.take(2).map(&:last))
      expect(@submissions).to be_empty
    end

    [false, true].each do |fork|
      it "retains single #{provider} repository behavior with fork=#{fork}" do
        url, endpoint = repository(provider, 1, git_suffix: true)
        @fork_by_endpoint[endpoint] = fork
        result = service([url], provider).execute
        expect(result[:status]).to eq(!fork)
        expect(@lookups).to eq([endpoint])
        expect(@submissions.length).to eq(fork ? 0 : 1)
        expect(@submissions.first.first).to eq("create_#{provider}_pull".to_sym) unless fork
      end
    end
  end

  ['github', 'gitee'].each do |origin|
    it "checks mixed providers while using the selected #{origin} workflow destination" do
      fixtures = [repository('github', 1), repository('gitee', 2)]
      fixtures.each { |_url, endpoint| @fork_by_endpoint[endpoint] = false }
      result = service(fixtures.map(&:first), origin).execute
      expect(result[:status]).to eq(true)
      expect(@lookups).to eq(fixtures.map(&:last))
      expect(@submissions.length).to eq(1)
      expect(@submissions.first.first).to eq("create_#{origin}_pull_with_multiple_files".to_sym)
    end
  end

  it 'rejects six repositories before lookup or submission' do
    fixtures = (1..6).map { |n| repository('github', n) }
    result = service(fixtures.map(&:first), 'github').execute
    expect(result).to include(status: false, message: 'pull.too_many_repositories')
    expect(@lookups).to be_empty
    expect(@submissions).to be_empty
  end
end
