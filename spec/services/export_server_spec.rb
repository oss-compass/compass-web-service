# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'pathname'
require 'uri'
require 'logger'

RSpec.describe 'ExportServer repository list' do
  around do |example|
    Dir.mktmpdir do |directory|
      @directory = directory
      example.run
    end
  end

  before do
    stub_const('Common', Module.new)
    stub_const('GithubApplication', Module.new)
    stub_const('ExportServer', Class.new)
    load File.expand_path('../../app/services/export_server.rb', __dir__)
    stub_const('ExportServer::META_REPO', 'metadata')
    stub_const('ExportServer::PROXY', 'http://127.0.0.1:1')
    stub_const('Rails', double(root: Pathname.new(@directory)))
    Dir.mkdir(File.join(@directory, 'metadata'))
    File.write(csv_path, "repo_url\nhttps://github.com/original/repo\n")
    allow(server).to receive(:job_logger).and_return(Logger.new(File::NULL))
  end

  let(:index) { double('index') }
  let(:server) { ExportServer.new(index, 'label.keyword', 100, 2) }
  let(:csv_path) { File.join(@directory, 'metadata', 'all_repositories.csv') }

  def stub_partitions(fail_second: false)
    call = 0
    allow(index).to receive(:aggregate) do
      call += 1
      raise IOError, 'query unavailable' if fail_second && call == 2

      url = call == 1 ? 'https://github.com/z/repo' : 'https://github.com/a/repo'
      double(page: double(aggregations: { 'distinct_values' => { 'buckets' => [{ 'key' => url }] } }))
    end
  end

  it 'keeps the existing CSV if a later partition fails' do
    stub_partitions(fail_second: true)
    original = File.read(csv_path)
    server.export_repos_to_csv('all_repositories.csv')
    expect(File.read(csv_path)).to eq(original)
    expect(Dir.children(File.dirname(csv_path))).to eq(['all_repositories.csv'])
  end

  it 'does not invoke Git after an export failure' do
    stub_partitions(fail_second: true)
    expect(Open3).not_to receive(:capture2)
    expect { server.execute }.not_to raise_error
  end

  it 'replaces the CSV with all sorted partitions after a successful export' do
    stub_partitions
    server.export_repos_to_csv('all_repositories.csv')
    expect(CSV.read(csv_path)).to eq([
      ['repo_url'], ['https://github.com/a/repo'], ['https://github.com/z/repo']
    ])
    expect(Dir.children(File.dirname(csv_path))).to eq(['all_repositories.csv'])
  end
end
