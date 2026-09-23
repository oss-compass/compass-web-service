# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateSubscription do
  it 'subscribes when a later metric index has data but the activity index does not' do
    mutation = described_class.allocate
    subscriptions = double('subscriptions')
    user = double('user', subscriptions: subscriptions)
    label = 'https://example.com/repo'
    updated_at = '2025-01-02T00:00:00Z'
    empty_response = { 'hits' => { 'hits' => [] } }
    community_response = { 'hits' => { 'hits' => [{ '_source' => { 'metadata__enriched_on' => updated_at } }] } }

    allow(mutation).to receive(:context).and_return(current_user: user)
    allow(mutation).to receive(:login_required!)
    allow(ShortenedLabel).to receive(:normalize_label).and_return(label)
    allow(Subject).to receive(:find_by).with(label: label).and_return(nil)
    allow(subscriptions).to receive_message_chain(:joins, :find_by).and_return(nil)
    allow(ProjectTask).to receive(:find_by).and_return(nil)
    allow(ActivityMetric).to receive(:query_label_one).and_return(empty_response)
    allow(CommunityMetric).to receive(:query_label_one).and_return(community_response)
    allow(CodequalityMetric).to receive(:query_label_one).and_return(empty_response)
    allow(GroupActivityMetric).to receive(:query_label_one).and_return(empty_response)

    subject = double('subject')
    expect(Subject).to receive(:create).with(
      label: label, level: 'repo', status: Subject::COMPLETE, status_updated_at: updated_at, count: 1
    ).and_return(subject)
    expect(subscriptions).to receive(:create).with(subject: subject)

    expect(mutation.resolve(label: label, level: 'repo')).to eq(status: true)
  end
end
