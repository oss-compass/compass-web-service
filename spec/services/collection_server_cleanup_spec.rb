require 'rails_helper'
require 'json'
require 'ostruct'

RSpec.describe CollectionServer do
  describe '#clean_expired' do
    subject(:server) { described_class.new }

    let(:endpoint) { 'http://search.example.test:9200' }
    let(:http) { double('SearchFlip HTTP client') }
    let(:connection) do
      SearchFlip::Connection.new(base_url: endpoint, http_client: http)
    end

    before do
      @requests = []
      @pending_responses = []
      @remaining = {}
      @deleted_ids = []
      @delete_attempts = []
      @delete_errors = {}

      # Only the HTTP transport and record persistence are replaced. Criteria,
      # scroll iteration, Response and Result are the real SearchFlip classes.
      allow(BaseCollection).to receive(:connection).and_return(connection)
      allow(http).to receive(:headers).with(accept: 'application/json').and_return(http)
      allow(http).to receive(:get).with("#{endpoint}/").and_return(
        JSON.generate('version' => { 'number' => '7.10.2' })
      )
      allow(http).to receive(:post) do |url, params:, json:|
        @requests << { url: url, params: params, body: json }
        raise 'unexpected extra search request' if @pending_responses.empty?

        response = @pending_responses.shift
        raise response if response.is_a?(Exception)

        response
      end
      allow(BaseCollection).to receive(:delete) do |model|
        @delete_attempts << model.id
        original = @remaining.fetch(model.id)
        expect(model).to be_a(OpenStruct)
        expect(model.to_h).to eq(original.transform_keys(&:to_sym))
        raise @delete_errors.fetch(model.id) if @delete_errors.key?(model.id)

        @deleted_ids << model.id
        @remaining.delete(model.id)
        model
      end
    end

    def document(id, months_ago: 8)
      {
        'id' => id,
        'label' => "https://github.com/example/#{id}",
        'collection' => 'example',
        'level' => 'repo',
        'updated_at' => (Date.today << months_ago).to_time.utc.iso8601
      }
    end

    def remember_documents(documents)
      @remaining = documents.to_h { |entry| [entry.fetch('id'), entry.dup] }
    end

    # These are fixed backend response pages, not another query/scroll parser.
    # Their bytes stay fixed as the persistence boundary removes live records.
    def respond_with_pages(pages, total:)
      @pending_responses = pages.each_with_index.map do |page, index|
        next page if page.is_a?(Exception)

        JSON.generate(
          '_scroll_id' => "cursor-#{index + 1}",
          'hits' => {
            'total' => { 'value' => total, 'relation' => 'eq' },
            'hits' => page.map { |entry| { '_id' => entry.fetch('id'), '_source' => entry } }
          }
        )
      end
    end

    def expect_scroll_trace(count, lte: 6.months)
      expect(@requests.length).to eq(count)
      first = @requests.fetch(0)
      expect(first[:url]).to eq("#{BaseCollection.type_url}/_search")
      expect(first[:params]).to eq(scroll: '1m')
      expect(first[:body]).to eq(
        query: { bool: { filter: [{ range: { updated_at: { lte: Date.today.end_of_day - lte } } }] } },
        from: 0,
        size: 100
      )
      @requests.drop(1).each_with_index do |request, index|
        expect(request[:url]).to eq("#{endpoint}/_search/scroll")
        expect(request[:params]).to eq({})
        expect(request[:body]).to eq(scroll: '1m', scroll_id: "cursor-#{index + 1}")
      end
    end

    it 'does not delete anything when no collection is expired' do
      respond_with_pages([[]], total: 0)

      server.clean_expired

      expect(@deleted_ids).to eq([])
      expect(@delete_attempts).to eq([])
      expect(@pending_responses).to eq([])
      expect_scroll_trace(1)
    end

    it 'deletes a small set with the original record fields' do
      old = (1..5).map { |number| document("old-#{number}") }
      remember_documents(old)
      respond_with_pages([old, []], total: 5)

      server.clean_expired

      expect(@deleted_ids).to eq(%w[old-1 old-2 old-3 old-4 old-5])
      expect(@remaining).to eq({})
      expect(@pending_responses).to eq([])
      expect_scroll_trace(2)
    end

    it 'deletes all 65 matches rather than the default first 30' do
      old = (1..65).map { |number| document("old-#{number}") }
      remember_documents(old)
      respond_with_pages([old, []], total: 65)

      server.clean_expired

      expect(@deleted_ids).to eq((1..65).map { |number| "old-#{number}" })
      expect(@deleted_ids.uniq.length).to eq(65)
      expect(@remaining).to eq({})
      expect(@pending_responses).to eq([])
      expect_scroll_trace(2)
    end

    it 'visits three immutable batches without skipping deleted rows or recent data' do
      old = (1..205).map { |number| document("old-#{number}") }
      recent = [document('recent-1', months_ago: 1), document('recent-2', months_ago: 1)]
      remember_documents(old + recent)
      respond_with_pages([old[0, 100], old[100, 100], old[200, 5], []], total: 205)

      server.clean_expired

      expect(@deleted_ids).to eq((1..205).map { |number| "old-#{number}" })
      expect(@deleted_ids.uniq.length).to eq(205)
      expect(@remaining.keys).to contain_exactly('recent-1', 'recent-2')
      expect(@pending_responses).to eq([])
      expect_scroll_trace(4)
    end

    it 'keeps the caller-supplied expiry duration in the query' do
      older = document('eight-months-old')
      middle = document('three-months-old', months_ago: 3)
      recent = document('one-month-old', months_ago: 1)
      remember_documents([older, middle, recent])
      respond_with_pages([[older, middle], []], total: 2)

      server.clean_expired(lte: 2.months)

      expect(@deleted_ids).to eq(%w[eight-months-old three-months-old])
      expect(@remaining.keys).to eq(['one-month-old'])
      expect(@pending_responses).to eq([])
      expect_scroll_trace(2, lte: 2.months)
    end

    it 'propagates an initial search error without deleting records' do
      error = SearchFlip::ConnectionError.new('initial search failed')
      respond_with_pages([error], total: 0)

      expect { server.clean_expired }.to raise_error { |actual| expect(actual).to equal(error) }

      expect(@delete_attempts).to eq([])
      expect(@pending_responses).to eq([])
      expect_scroll_trace(1)
    end

    it 'propagates a later scroll error after the completed batch' do
      old = (1..101).map { |number| document("old-#{number}") }
      error = SearchFlip::ConnectionError.new('scroll failed')
      remember_documents(old)
      respond_with_pages([old[0, 100], error], total: 101)

      expect { server.clean_expired }.to raise_error { |actual| expect(actual).to equal(error) }

      expect(@deleted_ids).to eq((1..100).map { |number| "old-#{number}" })
      expect(@remaining.keys).to eq(['old-101'])
      expect(@pending_responses).to eq([])
      expect_scroll_trace(2)
    end

    it 'propagates a deletion error before processing the next record' do
      old = [document('old-1'), document('old-2'), document('old-3')]
      error = StandardError.new('delete failed')
      remember_documents(old)
      respond_with_pages([old, []], total: 3)
      @delete_errors['old-2'] = error

      expect { server.clean_expired }.to raise_error { |actual| expect(actual).to equal(error) }

      expect(@delete_attempts).to eq(%w[old-1 old-2])
      expect(@deleted_ids).to eq(['old-1'])
      expect(@remaining.keys).to contain_exactly('old-2', 'old-3')
      expect_scroll_trace(1)
    end

    it 'preserves a deletion error in a later batch without continuing the scroll' do
      old = (1..102).map { |number| document("old-#{number}") }
      error = StandardError.new('later delete failed')
      remember_documents(old)
      respond_with_pages([old[0, 100], old[100, 2], []], total: 102)
      @delete_errors['old-101'] = error

      expect { server.clean_expired }.to raise_error { |actual| expect(actual).to equal(error) }

      expect(@delete_attempts).to eq((1..101).map { |number| "old-#{number}" })
      expect(@deleted_ids).to eq((1..100).map { |number| "old-#{number}" })
      expect(@remaining.keys).to contain_exactly('old-101', 'old-102')
      expect_scroll_trace(2)
    end
  end
end
