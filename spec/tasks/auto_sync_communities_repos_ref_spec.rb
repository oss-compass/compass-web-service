# frozen_string_literal: true

require 'rspec'
require 'rake'
require 'yaml'
require 'tmpdir'
require 'fileutils'
require 'pathname'
require 'active_support'
require 'active_support/core_ext/time'

RSpec.describe 'db:sync_refs_between_communities_and_repos' do
  let(:software_url) { 'https://github.com/example/software' }
  let(:replacement_url) { 'https://github.com/example/replacement' }
  let(:governance_url) { 'https://github.com/example/governance' }
  let(:stored_software) { [software_url] }
  let(:stored_governance) { [] }
  let(:software_urls) { [software_url] }
  let(:governance_urls) { [] }
  let(:stored_count) { (stored_software + stored_governance).uniq.length }
  let(:software_relation) { double('software repositories', pluck: stored_software) }
  let(:governance_relation) { double('governance repositories', pluck: stored_governance) }
  let(:subject_record) do
    double('community subject', count: stored_count, status: 'pending',
           status_updated_at: Time.utc(2026, 1, 1), software_repos: software_relation,
           governance_repos: governance_relation)
  end

  around do |example|
    previous_application = Rake.application
    Rake.application = Rake::Application.new
    Dir.mktmpdir('compass-sync-refs') do |directory|
      @metadata_root = directory
      example.run
    end
  ensure
    Rake.application = previous_application
  end

  before do
    stub_const('Common', Module.new)
    stub_const('META_REPO', 'metadata')
    stub_const('Rails', double('Rails', root: Pathname.new(@metadata_root)))
    stub_const('Subject', Class.new do
      def self.find_or_initialize_by(attributes) = nil
      def self.sync_subject_repos_refs(subject, new_software_repos: [], new_governance_repos: []) = nil
    end)
    stub_const('Subject::PENDING', 'pending')
    communities = File.join(@metadata_root, META_REPO, 'communities')
    FileUtils.mkdir_p(communities)
    document = {
      'community_name' => 'Example',
      'resource_types' => {
        'software-artifact-repositories' => { 'repo_urls' => software_urls },
        'governance-repositories' => { 'repo_urls' => governance_urls }
      }
    }
    File.write(File.join(communities, 'example.yml'), YAML.dump(document))
    allow(Subject).to receive(:find_or_initialize_by).with({ label: 'Example' }).and_return(subject_record)
    allow(subject_record).to receive(:level=).with('community')
    allow(subject_record).to receive(:save!)
    allow(subject_record).to receive(:update!).with(count: (software_urls + governance_urls).uniq.length)
    Rake::Task.define_task(:environment)
    load File.expand_path('../../lib/tasks/auto_sync_communities_repos_ref.rake', __dir__)
  end

  def invoke_task
    Rake::Task['db:sync_refs_between_communities_and_repos'].invoke
  end

  shared_examples 'changed references' do
    it 'synchronizes the repository lists from the metadata' do
      expect(Subject).to receive(:sync_subject_repos_refs).with(
        subject_record, { new_software_repos: software_urls, new_governance_repos: governance_urls }
      )
      expect(subject_record).to receive(:update!).with(count: (software_urls + governance_urls).uniq.length)
      expect { invoke_task }.to output(/refresh .* successfully/).to_stdout
    end
  end

  context 'when a software repository is replaced without changing the count' do
    let(:software_urls) { [replacement_url] }

    include_examples 'changed references'
  end

  context 'when a governance repository is replaced without changing the count' do
    let(:stored_governance) { [governance_url] }
    let(:governance_urls) { [replacement_url] }

    include_examples 'changed references'
  end

  context 'when repositories exchange software and governance roles' do
    let(:stored_governance) { [governance_url] }
    let(:software_urls) { [governance_url] }
    let(:governance_urls) { [software_url] }

    include_examples 'changed references'
  end

  context 'when an existing software repository also becomes a governance repository' do
    let(:governance_urls) { [software_url] }

    include_examples 'changed references'
  end

  context 'when the repository count increases' do
    let(:software_urls) { [software_url, replacement_url] }

    include_examples 'changed references'
  end

  context 'when all repositories are removed' do
    let(:software_urls) { [] }

    include_examples 'changed references'
  end

  context 'when only the repository order and duplicates differ' do
    let(:stored_software) { [software_url, replacement_url] }
    let(:software_urls) { [replacement_url, software_url, software_url] }

    it 'keeps unchanged references without synchronizing them' do
      expect(Subject).not_to receive(:sync_subject_repos_refs)
      expect(subject_record).not_to receive(:update!)
      expect { invoke_task }.to output(/no changes/).to_stdout
    end
  end
end
