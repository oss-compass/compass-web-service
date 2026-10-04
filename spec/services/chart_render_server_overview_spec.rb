# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ChartRenderServer overview dates' do
  before do
    stub_const('Common', Module.new)
    stub_const('Director', Module.new)
    stub_const('CompassUtils', Module.new)
    load File.expand_path('../../app/controllers/concerns/compass_utils.rb', __dir__)
    stub_const('ChartRenderServer', Class.new)
    load File.expand_path('../../app/services/chart_render_server.rb', __dir__)
    %w[ActivityMetric CommunityMetric CodequalityMetric GroupActivityMetric].each do |name|
      stub_const(name, Class.new do
        def self.main_score
          'score'
        end

        def self.i18n_name
          name
        end
      end)
    end
  end

  let(:server) { ChartRenderServer.new(metric: 'overview', lable: 'https://github.com/org/repo') }

  def render_series(series)
    [ActivityMetric, CommunityMetric, CodequalityMetric, GroupActivityMetric].zip(series).each do |metric, data|
      method = metric == GroupActivityMetric ? :build_metrics_with_agg : :build_metrics_with_search
      allow(server).to receive(method).with(metric, nil).and_return(data)
    end
    allow(server).to receive(:generate_title).and_return('Overview')
    allow(server).to receive(:request_svg) { |payload| payload }
    server.render![:option]
  end

  it 'aligns each metric to the union of dates and retains numeric zero' do
    option = render_series([
      [['2024-01-01', '2024-03-01'], [1, 3]],
      [['2024-02-01', '2024-03-01'], [0, 4]],
      [[], []],
      [['2024-04-01'], [5]]
    ])
    expect(option[:xAxis][:data]).to eq(%w[2024-01-01 2024-02-01 2024-03-01 2024-04-01])
    expect(option[:series].map { |series| series[:data] }).to eq([
      [1, nil, 3, nil], [nil, 0, 4, nil], [nil, nil, nil, nil], [nil, nil, nil, 5]
    ])
  end

  it 'preserves data when all metrics share the same dates' do
    option = render_series(Array.new(4) { [%w[2024-01-01 2024-02-01], [0, 2]] })
    expect(option[:xAxis][:data]).to eq(%w[2024-01-01 2024-02-01])
    expect(option[:series].map { |series| series[:data] }).to eq(Array.new(4) { [0, 2] })
  end

  it 'keeps an empty overview renderable' do
    option = render_series(Array.new(4) { [[], []] })
    expect(option[:xAxis][:data]).to eq([])
    expect(option[:series].map { |series| series[:data] }).to eq(Array.new(4) { [] })
  end
end
