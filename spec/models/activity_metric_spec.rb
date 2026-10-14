require 'rails_helper'

RSpec.describe ActivityMetric do
  describe '.build_snapshot' do
    let(:label) { 'https://github.com/example/project' }
    let(:timestamp) { '2026-10-12T00:00:00.000Z' }
    let(:bucket) do
      { 'key_as_string' => timestamp, 'avg_activity' => { 'value' => 12.5 } }
    end
    let(:buckets) { [bucket] }
    let(:client) { double('Elasticsearch HTTP client') }
    let(:connection) { double('Elasticsearch connection', version: '8', base_url: 'http://localhost:9200', http_client: client) }

    before do
      allow(described_class).to receive(:connection).and_return(connection)
      allow(connection).to receive(:index_url).with(described_class.index_name).and_return('http://localhost:9200/activity')
      allow(client).to receive(:headers).with(accept: 'application/json').and_return(client)
      allow(client).to receive(:post) do
        { 'aggregations' => { 'arise' => { 'buckets' => buckets } } }.to_json
      end
    end

    it 'builds a snapshot when the first weekly bucket has no derivative' do
      expect(described_class.build_snapshot(label)).to eq(
        label: label,
        level: 'repo',
        activity_score: 12.5,
        activity_delta: 0,
        updated_at: DateTime.parse(timestamp)
      )
    end

    it 'uses zero when the derivative value is null' do
      bucket['the_delta'] = { 'value' => nil }
      expect(described_class.build_snapshot(label)[:activity_delta]).to eq(0)
    end

    [3.5, -2.5, 0.0].each do |delta|
      it "preserves an available derivative of #{delta}" do
        bucket['the_delta'] = { 'value' => delta }
        expect(described_class.build_snapshot(label)[:activity_delta]).to eq(delta)
      end
    end

    context 'without recent histogram buckets' do
      let(:buckets) { [] }

      it 'falls back to the latest document with zero delta' do
        allow(described_class).to receive(:query_label_one).with(label, 'repo').and_return(
          'hits' => { 'hits' => [{ '_source' => { 'activity_score' => 8.0, 'grimoire_creation_date' => timestamp } }] }
        )
        expect(described_class.build_snapshot(label)).to eq(
          label: label,
          level: 'repo',
          activity_score: 8.0,
          activity_delta: 0,
          updated_at: DateTime.parse(timestamp)
        )
      end

      it 'returns nil when there is no activity document' do
        allow(described_class).to receive(:query_label_one).with(label, 'repo').and_return('hits' => { 'hits' => [] })
        expect(described_class.build_snapshot(label)).to be_nil
      end
    end
  end
end
