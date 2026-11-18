# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportServer do
  let(:server) { described_class.new(nil, nil, nil, nil) }
  let(:chdir) { (Rails.root + described_class::META_REPO).to_s }
  let(:proxy) { 'http://proxy.example.invalid/$PROXY_INJECTION' }
  let(:token) { 'token; touch /tmp/export_server_injection' }
  let(:status) { instance_double(Process::Status, success?: true) }
  let(:commit_time) { DateTime.new(2026, 1, 2, 3, 4, 5) }
  let(:captured_calls) { [] }
  let(:expected_calls) do
    [
      [[{ 'https_proxy' => proxy }, 'git', 'pull'], { chdir: chdir }],
      [['git', 'add', described_class::REPOS_CSV], { chdir: chdir }],
      [['git', 'commit', '-s', '-m', "Update at #{commit_time}"], { chdir: chdir }],
      [['git', 'config', 'credential.username', 'oss-compass-bot'], { chdir: chdir }],
      [[
        'git', 'config', 'credential.helper',
        '!f() { echo "password=$GITHUB_TOKEN"; }; f'
      ], { chdir: chdir }],
      [[{ 'https_proxy' => proxy, 'GITHUB_TOKEN' => token }, 'git', 'push', 'origin', 'main'],
       { chdir: chdir }]
    ]
  end

  before do
    stub_const('Common::PROXY', proxy)
    stub_const('GithubApplication::GITHUB_TOKEN', token)
    allow(DateTime).to receive(:now).and_return(commit_time)
    allow(server).to receive(:export_repos_to_csv)
    allow(Open3).to receive(:capture2) do |*args, **options|
      captured_calls << [args, options]
      ['', status]
    end
  end

  it 'passes proxy and token values outside git argv' do
    server.execute

    expect(captured_calls).to eq(expected_calls)
  end
end
