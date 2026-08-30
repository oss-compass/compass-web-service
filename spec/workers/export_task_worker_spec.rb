# frozen_string_literal: true

require 'rails_helper'
require 'timeout'

RSpec.describe ExportTaskWorker do
  subject(:worker) { described_class.new }

  # Mimics the search_flip (3.7.0) Criteria/Response scroll semantics the
  # worker relies on:
  #   - Criteria#execute returns a Response for the next batch
  #   - Response#raw_response / #scroll_id
  #   - scroll(id: nil) starts a brand-new initial scroll from batch 0,
  #     which is exactly what made the old last_page?-driven loop spin forever
  #     once the scroll context was exhausted
  let(:fake_indexer) do
    Class.new do
      Response = Class.new do
        def initialize(raw)
          @raw = raw
        end

        def raw_response
          @raw
        end

        def scroll_id
          @raw['_scroll_id']
        end
      end

      class << self
        attr_accessor :scroll_batches

        def must(_query)
          new(scroll_batches)
        end
      end

      def initialize(batches, next_idx = 0)
        @batches = batches
        @idx = next_idx - 1
      end

      def per(_n)
        self
      end

      def scroll(timeout: nil, id: nil)
        raise 'blank scroll_id must terminate the loop, not restart it' if id.nil?

        self.class.new(@batches, @idx + 1)
      end

      def execute
        @idx += 1
        @response = Response.new(@batches.fetch(@idx))
      end

      def scroll_id
        @response.scroll_id
      end
    end
  end

  let(:fake_callback) do
    Module.new do
      class << self
        attr_accessor :processed, :finished

        def on_each(args)
          (@processed ||= []) << args[:source]['title']
          { 'title' => args[:source]['title'] }
        end

        def on_finish(args)
          @finished = args
        end
      end
    end
  end

  let(:uuid) { 'specexport' }
  let(:temp_csv) { Rails.root.join("tmp/uploads/temp_#{uuid}.csv") }
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    FileUtils.mkdir_p(Rails.root.join('tmp/uploads'))
    allow(Rails).to receive(:cache).and_return(cache)
    allow(Subject).to receive(:find_by).and_return(nil)
    allow_any_instance_of(described_class).to receive(:ack!)
    stub_const('FakeExportIndexer', fake_indexer)
    stub_const('FakeExportCallback', fake_callback)
  end

  def message_for(batches)
    fake_indexer.scroll_batches = batches
    {
      label: 'repo', level: 'repo', uuid: uuid, query: { 'bool' => {} },
      select: %w[title state], indexer: 'FakeExportIndexer',
      callback_module: 'FakeExportCallback', each_callback_function: 'on_each',
      finish_callback_function: 'on_finish', per_page: 2
    }.to_json
  end

  it 'exports every scroll batch and finishes (multi-batch, exhausted scroll without scroll_id)' do
    batches = [
      { 'hits' => { 'hits' => [{ '_source' => { 'title' => 't1' } }, { '_source' => { 'title' => 't2' } }] }, '_scroll_id' => 's1' },
      { 'hits' => { 'hits' => [{ '_source' => { 'title' => 't3' } }] }, '_scroll_id' => 's2' },
      { 'hits' => { 'hits' => [] } }
    ]

    expect { Timeout.timeout(10) { worker.work(message_for(batches)) } }.not_to raise_error

    expect(fake_callback.processed).to eq(%w[t1 t2 t3])
    expect(fake_callback.finished).to include(uuid: uuid, blob_id: nil)
    expect(File.exist?(temp_csv)).to be(false)
    expect(cache.read("export-#{uuid}")).to be_present
  end

  it 'stops when the final non-empty batch carries no scroll_id' do
    batches = [
      { 'hits' => { 'hits' => [{ '_source' => { 'title' => 't1' } }] } }
    ]

    expect { Timeout.timeout(10) { worker.work(message_for(batches)) } }.not_to raise_error

    expect(fake_callback.processed).to eq(%w[t1])
    expect(fake_callback.finished).to be_present
  end

  it 'handles zero matches without invoking the row callback' do
    batches = [{ 'hits' => { 'hits' => [] } }]

    expect { Timeout.timeout(10) { worker.work(message_for(batches)) } }.not_to raise_error

    expect(fake_callback.processed).to be_nil
    expect(fake_callback.finished).to be_present
  end
end
