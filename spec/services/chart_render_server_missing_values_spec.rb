# frozen_string_literal: true
require 'spec_helper'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'

RSpec.describe 'ChartRenderServer missing metric values' do
  before do
    stub_const('Common', Module.new)
    stub_const('Director', Module.new)
    stub_const('CompassUtils', Module.new)
    load File.expand_path('../../app/controllers/concerns/compass_utils.rb', __dir__)
    stub_const('ChartRenderServer', Class.new)
    load File.expand_path('../../app/services/chart_render_server.rb', __dir__)
    stub_const('ActivityMetric', Class.new do
      def self.main_score; 'score'; end
      def self.fields_aliases; { 'contributors' => 'contributors_count' }; end
      def self.query_repo_by_date(*args, **kwargs); end
      def self.aggs_repo_by_date(*args, **kwargs); end
      def self.scaled_value(_source, target_value:); target_value.to_f * 100; end
    end)
    stub_const('Types', Module.new)
    stub_const('Types::ActivityMetricType', Class.new)
  end

  def server(**params)
    instance = ChartRenderServer.new({ metric: 'activity', lable: 'example' }.merge(params))
    allow(instance).to receive(:generate_title).and_return('Activity')
    allow(instance).to receive(:generate_subtext).and_return('')
    allow(instance).to receive(:generate_interval_aggs).and_return({})
    allow(instance).to receive(:request_svg) { |payload| payload }
    instance
  end

  def raw_response(values)
    { 'hits' => { 'hits' => values.each_with_index.map { |value, i|
      { '_source' => { 'grimoire_creation_date' => "2024-01-0#{i + 1}", 'score' => value } }
    } } }
  end

  def aggregated_response(buckets, template = { 'score' => 9 })
    { 'hits' => { 'hits' => template ? [{ '_source' => template }] : [] },
      'aggregations' => { 'aggsWithDate' => { 'buckets' => buckets.each_with_index.map { |fields, i|
        { 'key_as_string' => "2024-01-0#{i + 1}" }.merge(fields)
      } } } }
  end

  it 'preserves raw gaps and zero, calculating bounds from available values' do
    allow(ActivityMetric).to receive(:query_repo_by_date).and_return(raw_response([nil, 0, 2.345]))
    option = server.render![:option]
    expect(option[:xAxis][:data].length).to eq(3)
    expect(option[:series][0][:data]).to eq([nil, 0, 2.35])
    expect(option[:yAxis][0].values_at(:min, :max)).to eq([-0.01, 4])
  end

  it 'does not transform an absent score into zero' do
    allow(ActivityMetric).to receive(:query_repo_by_date).and_return(raw_response([nil, 0.5]))
    expect(server(y_trans: '1').render![:option][:series][0][:data]).to eq([nil, 50])
  end

  it 'renders all-missing raw data with finite default bounds' do
    allow(ActivityMetric).to receive(:query_repo_by_date).and_return(raw_response([nil]))
    option = server.render![:option]
    expect(option[:series][0][:data]).to eq([nil])
    expect(option[:yAxis][0].values_at(:min, :max)).to eq([-0.01, 0.01])
  end

  it 'keeps null bucket averages instead of substituting the first document value' do
    allow(ActivityMetric).to receive(:aggs_repo_by_date).and_return(
      aggregated_response([{ 'score' => { 'value' => nil } }, { 'score' => { 'value' => 0 } }])
    )
    expect(server(interval: '1M').render![:option][:series][0][:data]).to eq([nil, 0])
  end

  it 'handles buckets without a source hit or metric value' do
    allow(ActivityMetric).to receive(:aggs_repo_by_date).and_return(aggregated_response([{}], nil))
    expect(server(interval: '1M').render![:option][:series][0][:data]).to eq([nil])
  end

  it 'retains aliased averages and template fallback for non-aggregated fields' do
    allow(ActivityMetric).to receive(:aggs_repo_by_date).and_return(
      aggregated_response([{ 'contributors_count' => { 'value' => 1.234 } }, {}], { 'contributors_count' => 7 })
    )
    expect(server(interval: '1M', field: 'contributors').render![:option][:series][0][:data]).to eq([1.23, 7])
  end
end
