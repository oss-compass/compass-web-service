require 'rails_helper'

RSpec.describe TpcSoftwareSelection, type: :model do
  describe '.perform_gitcode_automation permission failures' do
    let(:report) { double('report', code_url: nil, adaptation_method: 'Java库重写') }
    let(:selection) do
      double('selection', id: 12, repo_url: 'https://gitcode.com/test-org/test-repo',
             tpc_software_report: report, functional_description: 'Test repository')
    end
    let(:member) { double('committer', gitcode_account: 'test-committer', role: 'push') }
    let(:organization) { double('organization', name: 'test-org', tpc_auto_create_committers: [member]) }
    let(:organizations) { double('organizations', first: organization) }
    let(:connection) { double('GitCode connection') }
    let(:server) { GitcodeServer.allocate }
    let(:get_status) { 200 }
    let(:get_body) { { memberMgntMode: 1 }.to_json }
    let(:put_status) { 403 }
    let(:put_body) { { error_message: 'permission transition denied' }.to_json }

    before do
      server.instance_variable_set(:@conn, connection)
      allow(connection).to receive(:get).and_return(double(status: get_status, body: get_body))
      allow(connection).to receive(:put).and_return(double(status: put_status, body: put_body))
      allow(TpcAutoCreateOrg).to receive(:enabled).and_return(organizations)
      allow(organizations).to receive(:where).with('LOWER(org_url) = ?', 'https://gitcode.com/test-org').and_return(organizations)
      allow(GitcodeServer).to receive(:new).and_return(server)
      allow(server).to receive(:create_repo).and_return(true)
      allow(server).to receive(:add_collaborator).and_return(true)
      allow(server).to receive(:create_label).and_return(true)
      allow(described_class).to receive(:sleep)
    end

    def expect_no_followup_writes
      expect(server).not_to have_received(:add_collaborator)
      expect(server).not_to have_received(:create_label)
    end

    it 'stops when the transition returns an API error' do
      expect(described_class.perform_gitcode_automation(selection)).to eq('permission transition denied')
      expect_no_followup_writes
    end

    it 'records the transition failure instead of the repository-created state' do
      allow(described_class).to receive(:find_by).with(id: 12).and_return(selection)
      allow(described_class).to receive(:get_current_state).with(selection).and_return(described_class::State_Completed)
      allow(described_class).to receive(:check_auto_create_permission).with(selection).and_return(true)
      allow(selection).to receive(:update!)

      described_class.update_state(12)

      expect(selection).to have_received(:update!).with(state: described_class::State_Repo_Created_Error, remark: 'permission transition denied')
      expect(selection).not_to have_received(:update!).with(state: described_class::State_Repo_Created)
      expect_no_followup_writes
    end

    context 'when reading the current permission mode is denied' do
      let(:get_status) { 403 }
      let(:get_body) { { message: 'read denied' }.to_json }

      it 'propagates the failure instead of the successful repository-creation result' do
        expect(described_class.perform_gitcode_automation(selection)).to include('获取权限模式失败 (Status: 403)')
        expect_no_followup_writes
      end
    end

    context 'when the permission response cannot be parsed' do
      let(:get_body) { 'not json' }

      it 'returns the parse failure and skips follow-up writes' do
        expect(described_class.perform_gitcode_automation(selection)).to include('解析权限模式响应失败')
        expect_no_followup_writes
      end
    end

    context 'when the API error has no error_message field' do
      let(:put_body) { { message: 'denied' }.to_json }

      it 'returns a useful failure instead of continuing with nil' do
        expect(described_class.perform_gitcode_automation(selection)).to eq('Failed to configure repository permissions')
        expect_no_followup_writes
      end
    end

    context 'when the permission transition succeeds' do
      let(:put_status) { 200 }
      let(:put_body) { '{}' }

      it 'continues assigning collaborators and the project label' do
        described_class.perform_gitcode_automation(selection)
        expect(server).to have_received(:add_collaborator).with('test-org', 'test-repo', 'test-committer', 'push')
        expect(server).to have_received(:create_label).with('test-org', 'test-repo', '孵化')
      end
    end

    context 'when the repository already uses independent permissions' do
      let(:get_body) { { memberMgntMode: 2 }.to_json }

      it 'continues without requesting a transition' do
        described_class.perform_gitcode_automation(selection)
        expect(connection).not_to have_received(:put)
        expect(server).to have_received(:add_collaborator)
        expect(server).to have_received(:create_label)
      end
    end
  end
end
