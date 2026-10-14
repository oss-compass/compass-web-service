require 'rails_helper'
require 'logger'
require 'stringio'

RSpec.describe TpcSoftwareSandbox do
  let(:repo_url) { 'https://gitcode.com/example/project' }
  let(:report) { double('sandbox report', code_url: 'https://github.com/example/source', adaptation_method: 'adaptation') }
  let(:sandbox) do
    double('sandbox', id: 7, repo_url: repo_url, functional_description: 'Example project',
           tpc_software_sandbox_report: report, update!: true)
  end
  let(:state) { described_class::State_Completed }
  let(:org) { double('organization', name: 'example', tpc_auto_create_committers: []) }
  let(:org_scope) { double('enabled organizations', pluck: ['https://gitcode.com/example']) }
  let(:gitcode) { instance_double(GitcodeServer, create_repo: true, update_repo_model: true, create_label: true) }

  before do
    allow(Rails).to receive(:logger).and_return(Logger.new(StringIO.new))
    allow(described_class).to receive(:find_by).with(id: 7).and_return(sandbox)
    allow(described_class).to receive(:get_current_state).with(sandbox).and_return(state)
    allow(described_class).to receive(:sleep)
    allow(TpcAutoCreateOrg).to receive(:enabled).and_return(org_scope)
    allow(org_scope).to receive(:where).with('LOWER(org_url) = ?', 'https://gitcode.com/example').and_return([org])
    allow(GitcodeServer).to receive(:new).and_return(gitcode)
  end

  it 'uses the sandbox through permission checks, creation and the final state update' do
    described_class.update_state(7)

    expect(gitcode).to have_received(:create_repo).with(hash_including(
      owner: 'example', name: 'project', description: 'Example project',
      import_url: 'https://github.com/example/source', auto_init: false
    ))
    expect(gitcode).to have_received(:update_repo_model).with('example', 'project')
    expect(gitcode).to have_received(:create_label).with('example', 'project', '沙箱')
    expect(sandbox).to have_received(:update!).with(state: described_class::State_Repo_Created)
  end

  it 'records a repository creation failure' do
    allow(gitcode).to receive(:create_repo).and_return('repository quota exceeded')

    described_class.update_state(7)

    expect(sandbox).to have_received(:update!).with(
      state: described_class::State_Repo_Created_Error, remark: 'repository quota exceeded'
    )
    expect(gitcode).not_to have_received(:update_repo_model)
    expect(gitcode).not_to have_received(:create_label)
  end

  it 'does not create a repository for an organization without permission' do
    allow(org_scope).to receive(:pluck).and_return(['https://gitcode.com/other'])

    described_class.update_state(7)

    expect(sandbox).to have_received(:update!).with(state: state).once
    expect(GitcodeServer).not_to have_received(:new)
  end

  context 'when review is incomplete' do
    let(:state) { described_class::State_Awaiting_Review }

    it 'updates the review state without starting repository creation' do
      described_class.update_state(7)

      expect(sandbox).to have_received(:update!).with(state: state).once
      expect(GitcodeServer).not_to have_received(:new)
    end
  end

  context 'without a repository URL' do
    let(:repo_url) { nil }

    it 'updates the review state without checking organizations or creating a repository' do
      described_class.update_state(7)

      expect(sandbox).to have_received(:update!).with(state: state).once
      expect(TpcAutoCreateOrg).not_to have_received(:enabled)
      expect(GitcodeServer).not_to have_received(:new)
    end
  end

  it 'uses the sandbox repository when automation is invoked directly for a Java rewrite' do
    allow(report).to receive(:adaptation_method).and_return('Java库重写')

    described_class.perform_gitcode_automation(sandbox)

    expect(gitcode).to have_received(:create_repo).with(hash_including(
      owner: 'example', name: 'project', import_url: nil, auto_init: true
    ))
  end
end
