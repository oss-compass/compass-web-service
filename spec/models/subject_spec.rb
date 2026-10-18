# == Schema Information
#
# Table name: subjects
#
#  id                :bigint           not null, primary key
#  label             :string(255)      not null
#  level             :string(255)      default("repo"), not null
#  status            :string(255)      default("pending"), not null
#  count             :integer          default(0), not null
#  status_updated_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  collect_at        :datetime
#  complete_at       :datetime
#
# Indexes
#
#  index_subjects_on_label  (label) UNIQUE
#
require 'rails_helper'

RSpec.describe Subject, type: :model do
  let(:parent) { double('community', label: 'example-community') }
  let(:label) { 'https://github.com/example/repo' }
  let(:repo_type) { SubjectRef::ToRepoSoftware }

  before do
    allow(Rails.logger).to receive(:error)
  end

  describe '.append_child' do
    it 'logs the original failure without raising another exception' do
      allow(described_class).to receive(:append_child!).with(parent, label, repo_type)
        .and_raise(ActiveRecord::RecordNotUnique, 'duplicate child link')

      expect { described_class.append_child(parent, label, repo_type) }.not_to raise_error
      expect(Rails.logger).to have_received(:error).with(
        "Unable to append child #{label} to example-community, error: duplicate child link"
      )
    end

    it 'returns the result of a successful append' do
      result = double('subject reference')
      allow(described_class).to receive(:append_child!).with(parent, label, repo_type).and_return(result)

      expect(described_class.append_child(parent, label, repo_type)).to eq(result)
      expect(Rails.logger).not_to have_received(:error)
    end
  end

  describe '.remove_child' do
    it 'logs the original failure without raising another exception' do
      allow(described_class).to receive(:remove_child!).with(parent, label, repo_type)
        .and_raise(ActiveRecord::StatementInvalid, 'delete failed')

      expect { described_class.remove_child(parent, label, repo_type) }.not_to raise_error
      expect(Rails.logger).to have_received(:error).with(
        "Unable to remove child #{label} from example-community, error: delete failed"
      )
    end

    it 'returns the result of a successful removal' do
      result = [double('subject reference')]
      allow(described_class).to receive(:remove_child!).with(parent, label, repo_type).and_return(result)

      expect(described_class.remove_child(parent, label, repo_type)).to eq(result)
      expect(Rails.logger).not_to have_received(:error)
    end
  end

  describe '.sync_subject_repos_refs' do
    it 'continues syncing other repositories after append and removal failures' do
      allow(parent).to receive(:software_repos).and_return(double(pluck: ['old-software']))
      allow(parent).to receive(:governance_repos).and_return(double(pluck: ['old-governance']))
      allow(described_class).to receive(:append_child!)
      allow(described_class).to receive(:remove_child!)
      allow(described_class).to receive(:append_child!).with(parent, 'failed-software', repo_type)
        .and_raise(ActiveRecord::RecordNotUnique, 'duplicate child link')
      allow(described_class).to receive(:remove_child!).with(parent, 'old-software', repo_type)
        .and_raise(ActiveRecord::StatementInvalid, 'delete failed')

      described_class.sync_subject_repos_refs(
        parent,
        new_software_repos: ['failed-software', 'new-software'],
        new_governance_repos: ['new-governance']
      )

      expect(described_class).to have_received(:append_child!).with(parent, 'new-software', repo_type)
      expect(described_class).to have_received(:append_child!)
        .with(parent, 'new-governance', SubjectRef::ToRepoGovernance)
      expect(described_class).to have_received(:remove_child!)
        .with(parent, 'old-governance', SubjectRef::ToRepoGovernance)
      expect(Rails.logger).to have_received(:error).twice
    end
  end
end
