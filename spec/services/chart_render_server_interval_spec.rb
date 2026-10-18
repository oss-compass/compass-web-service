# frozen_string_literal: true
require 'spec_helper'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'

RSpec.describe 'ChartRenderServer overview interval' do
  before do
    stub_const('Common', Module.new)
    stub_const('Director', Module.new)
    stub_const('CompassUtils', Module.new)
    load File.expand_path('../../app/controllers/concerns/compass_utils.rb', __dir__)
    stub_const('ChartRenderServer', Class.new)
    load File.expand_path('../../app/services/chart_render_server.rb', __dir__)
    stub_const('Types', Module.new)
    %w[ActivityMetric CommunityMetric CodequalityMetric GroupActivityMetric].each do |name|
      stub_const(name, Class.new do
        def self.main_score; 'score'; end
        def self.i18n_name; name; end
        def self.fields_aliases; {}; end
        def self.query_repo_by_date(*args, **kwargs); end
        def self.aggs_repo_by_date(*args, **kwargs); end
      end)
      stub_const("Types::#{name}Type", Class.new)
    end
  end

  def setup_server(interval)
    server = ChartRenderServer.new(metric: 'overview', lable: 'example', interval: interval,
                                   begin_date: '2020-01-01', end_date: '2023-01-01')
    allow(server).to receive(:generate_title).and_return('Overview')
    allow(server).to receive(:request_svg) { |payload| payload }
    allow(server).to receive(:generate_interval_aggs) { |_type, _field, selected| { interval: selected } }
    server
  end

  def aggregation_response
    { 'hits' => { 'hits' => [{ '_source' => { 'score' => 10 } }] },
      'aggregations' => { 'aggsWithDate' => { 'buckets' => [
        { 'key_as_string' => '2020-01-01', 'score' => { 'value' => 1 } },
        { 'key_as_string' => '2023-01-01', 'score' => { 'value' => 3 } }
      ] } } }
  end

  it 'uses the requested monthly aggregation for every overview metric' do
    server = setup_server('1M')
    [ActivityMetric, CommunityMetric, CodequalityMetric, GroupActivityMetric].each do |metric|
      expect(metric).not_to receive(:query_repo_by_date)
      expect(metric).to receive(:aggs_repo_by_date) do |label, first, last, aggs, kwargs|
        expect([label, first, last, aggs, kwargs]).to eq(
          ['example', '2020-01-01', '2023-01-01', { interval: '1M' }, { type: nil }]
        )
        aggregation_response
      end
    end
    option = server.render![:option]
    expect(option[:xAxis][:data]).to eq(%w[2020-01-01 2023-01-01])
    expect(option[:series].map { |series| series[:data] }).to eq(Array.new(4) { [1, 3] })
  end

  it 'keeps raw samples for short ranges and weekly aggregation for group activity' do
    server = setup_server(false)
    [ActivityMetric, CommunityMetric, CodequalityMetric].each do |metric|
      expect(metric).not_to receive(:aggs_repo_by_date)
      expect(metric).to receive(:query_repo_by_date).and_return(
        'hits' => { 'hits' => %w[2020-01-01 2023-01-01].map { |date|
          { '_source' => { 'grimoire_creation_date' => date, 'score' => 2 } }
        } }
      )
    end
    expect(GroupActivityMetric).to receive(:aggs_repo_by_date) do |_label, _first, _last, aggs, **_kwargs|
      expect(aggs).to eq(interval: '1w')
      aggregation_response
    end
    option = server.render![:option]
    expect(option[:series].map { |series| series[:data] }).to eq([[2, 2], [2, 2], [2, 2], [1, 3]])
  end
end
