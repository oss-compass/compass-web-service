require 'rails_helper'

RSpec.describe TpcSoftwareSelection, type: :model do
  describe '.get_current_state' do
    let(:selection) { double('selection', id: 12, target_software_report_id: 34) }
    let(:score) { nil }
    let(:metric) { double('report metric', upstream_collaboration_strategy: score) }
    let(:metrics) { double('report metrics', present?: true, take: metric) }
    let(:member_types) do
      [TpcSoftwareCommentState::Member_Type_Sig_Lead,
       TpcSoftwareCommentState::Member_Type_Legal]
    end
    let(:comments) { member_types.map { |member_type| accepted_review(member_type) } }

    def accepted_review(member_type)
      Struct.new(:member_type, :state).new(member_type, TpcSoftwareCommentState::State_Accept)
    end

    before do
      allow(described_class).to receive(:get_risk_metric_list).with(34).and_return([])
      allow(described_class).to receive(:get_clarified_metric_list).with(34).and_return([])
      allow(described_class).to receive(:get_confirmed_metric_list).with(34).and_return([])
      allow(described_class).to receive(:get_comment_state_list).with(12).and_return(comments)
      allow(TpcSoftwareReportMetric).to receive(:where).with(tpc_software_report_id: 34).and_return(metrics)
    end

    it 'awaits QA when the optional score is absent and the reviewers accept' do
      expect(described_class.get_current_state(selection)).to eq(described_class::State_Awaiting_QA)
    end

    it 'completes an unscored selection after QA also accepts' do
      comments << accepted_review(TpcSoftwareCommentState::Member_Type_QA)

      expect(described_class.get_current_state(selection)).to eq(described_class::State_Completed)
    end

    it 'keeps an unscored selection awaiting review when a reviewer is missing' do
      comments.reject! { |comment| comment.member_type == TpcSoftwareCommentState::Member_Type_Legal }

      expect(described_class.get_current_state(selection)).to eq(described_class::State_Awaiting_Review)
    end

    it 'preserves a rejection when the optional score is absent' do
      comments.first.state = TpcSoftwareCommentState::State_Reject

      expect(described_class.get_current_state(selection)).to eq(described_class::State_Rejected)
    end

    [-1, 10].each do |value|
      context "with a score of #{value}" do
        let(:score) { value }

        it 'does not require a collaboration working group review' do
          expect(described_class.get_current_state(selection)).to eq(described_class::State_Awaiting_QA)
        end
      end
    end

    [0, 9].each do |value|
      context "with a score of #{value}" do
        let(:score) { value }

        it 'still requires a collaboration working group review' do
          expect(described_class.get_current_state(selection)).to eq(described_class::State_Awaiting_Review)
        end

        it 'completes after the working group and QA accept' do
          comments << accepted_review(TpcSoftwareCommentState::Member_Type_Community_Collaboration_WG)
          comments << accepted_review(TpcSoftwareCommentState::Member_Type_QA)

          expect(described_class.get_current_state(selection)).to eq(described_class::State_Completed)
        end
      end
    end
  end
end
