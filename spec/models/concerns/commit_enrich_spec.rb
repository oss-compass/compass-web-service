# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommitEnrich do
  let(:indexer) { Class.new { include CommitEnrich } }
  let(:query) { double('commit search', raw_response: {}) }

  before do
    allow(indexer).to receive(:base_commit_list_by_repo_urls).and_return(query)
    allow(query).to receive(:aggregate).and_return(query)
    allow(query).to receive(:per).and_return(query)
    allow(query).to receive(:execute).and_return(query)
  end

  def bucket_sort_for(sort_opts)
    aggregation = nil
    allow(query).to receive(:aggregate) do |value|
      aggregation = value
      query
    end

    indexer.fetch_commit_agg_list_by_repo_urls(
      ['https://example.com/repo'], Date.today - 1, Date.today, 'master', sort_opts: sort_opts
    )
    aggregation.dig(:group_by_name, :aggs, :sort_bucket)
  end

  it 'keeps the default bucket order when sorting by a document field' do
    sort = Struct.new(:type, :direction).new('grimoire_creation_date', 'desc')

    expect(bucket_sort_for([sort])).to eq(
      bucket_sort: { sort: [{ lines_changed: { order: 'desc' } }] }
    )
  end

  it 'uses the requested order when sorting by total lines' do
    sort = Struct.new(:type, :direction).new('lines_total', 'asc')

    expect(bucket_sort_for([sort])).to eq(
      bucket_sort: { sort: [{ lines_total: { order: 'asc' } }] }
    )
  end
end
