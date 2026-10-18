require 'rails_helper'

RSpec.describe SubscriptionsUpdateWorker do
  let(:worker) { described_class.allocate }
  let(:previous_time) { Time.utc(2026, 1, 1) }
  let(:message_time) { Time.utc(2026, 1, 2) }
  let!(:community) do
    Subject.create!(label: 'example-community', level: 'community', status: Subject::PENDING,
                    count: 2, status_updated_at: previous_time)
  end
  let(:message) do
    { label: community.label, level: community.level, status: community.status,
      count: 5, status_updated_at: message_time.iso8601 }
  end

  before do
    allow(Sneakers).to receive(:logger).and_return(instance_double(Logger, info: nil))
  end

  it 'refreshes the repository count when the status is unchanged' do
    expect(worker.work(message.to_json)).to eq(:ack)

    community.reload
    expect(community.count).to eq(5)
    expect(community.status).to eq(Subject::PENDING)
    expect(community.status_updated_at).to eq(previous_time)
    expect(community.collect_at).to be_nil
    expect(community.complete_at).to be_nil
  end

  it 'refreshes the count of an already completed community without changing completion time' do
    community.update!(status: Subject::COMPLETE, complete_at: previous_time)

    worker.work(message.to_json)

    expect(community.reload.count).to eq(5)
    expect(community.complete_at).to eq(previous_time)
    expect(community.status_updated_at).to eq(previous_time)
  end

  [nil, 0, -1].each do |count|
    it "keeps the known count when the incoming count is #{count.inspect}" do
      worker.work(message.merge(count: count).to_json)

      expect(community.reload.count).to eq(2)
      expect(community.status_updated_at).to eq(previous_time)
    end
  end

  it 'does not write an unchanged status and count' do
    community.update_columns(updated_at: previous_time)

    worker.work(message.merge(count: community.count).to_json)

    expect(community.reload.updated_at).to eq(previous_time)
  end

  it 'still updates the collection timestamp on a transition to progress' do
    worker.work(message.merge(status: Subject::PROGRESS).to_json)

    community.reload
    expect(community.status).to eq(Subject::PROGRESS)
    expect(community.count).to eq(5)
    expect(community.status_updated_at).to eq(message_time)
    expect(community.collect_at).to eq(message_time)
  end

  it 'still updates the completion timestamp on a transition to complete' do
    worker.work(message.merge(status: Subject::COMPLETE).to_json)

    community.reload
    expect(community.status).to eq(Subject::COMPLETE)
    expect(community.count).to eq(5)
    expect(community.status_updated_at).to eq(message_time)
    expect(community.complete_at).to eq(message_time)
  end

  it 'creates a missing subject with the supplied repository count' do
    expect { worker.work(message.merge(label: 'new-community').to_json) }.to change(Subject, :count).by(1)

    created = Subject.find_by!(label: 'new-community')
    expect(created.count).to eq(5)
    expect(created.status_updated_at).to eq(message_time)
  end
end
