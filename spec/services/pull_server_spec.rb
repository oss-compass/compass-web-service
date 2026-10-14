require 'rails_helper'

RSpec.describe PullServer do
  shared_examples 'batch fork validation' do |platform|
    let(:urls) { ["https://#{platform}.com/example/first.git", "https://#{platform}.com/example/second"] }
    let(:server) do
      described_class.new(level: 'repo', project_urls: urls,
                          extra: { username: 'contributor', origin: platform })
    end
    let(:check_method) { "#{platform}_is_fork_repo" }
    let(:submit_method) { "create_#{platform}_pull_with_multiple_files" }
    let(:success) { { status: true, pr_url: 'https://example.test/pull/1' } }

    before do
      allow(server).to receive(check_method).and_return(status: true)
      allow(server).to receive(submit_method).and_return(success)
    end

    it 'checks each normalized repository URL before submitting' do
      expect(server.execute).to eq(success)

      urls.each do |url|
        expect(server).to have_received(check_method).with(url.chomp('.git')).once
      end
      expect(server).to have_received(submit_method).with(
        anything,
        hash_including("#{Common::SINGLE_DIR}/#{platform}/example/first.yml",
                       "#{Common::SINGLE_DIR}/#{platform}/example/second.yml"),
        anything, anything
      )
    end

    [0, 1].each do |fork_index|
      it "does not submit when repository #{fork_index + 1} is a fork" do
        failure = { status: false, message: 'Fork repositories are not supported' }
        allow(server).to receive(check_method).with(urls[fork_index].chomp('.git')).and_return(failure)

        expect(server.execute).to eq(failure)
        expect(server).not_to have_received(submit_method)
      end
    end
  end

  include_examples 'batch fork validation', 'github'

  context 'with Gitee repositories' do
    include_examples 'batch fork validation', 'gitee'
  end

  it 'uses the repository host for checks and the selected origin for submission' do
    github_url = 'https://github.com/example/first'
    gitee_url = 'https://gitee.com/example/second'
    server = described_class.new(level: 'repo', project_urls: [github_url, gitee_url],
                                  extra: { username: 'contributor', origin: 'gitee' })
    allow(server).to receive(:github_is_fork_repo).and_return(status: true)
    allow(server).to receive(:gitee_is_fork_repo).and_return(status: true)
    allow(server).to receive(:create_gitee_pull_with_multiple_files).and_return(status: true)

    expect(server.execute).to eq(status: true)
    expect(server).to have_received(:github_is_fork_repo).with(github_url)
    expect(server).to have_received(:gitee_is_fork_repo).with(gitee_url)
    expect(server).to have_received(:create_gitee_pull_with_multiple_files)
  end
end
