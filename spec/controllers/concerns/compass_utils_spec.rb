# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompassUtils do
  describe '#generate_interval_aggs' do
    it 'uses each summary field name when no source alias exists' do
      helper = Object.new.extend(described_class)
      stat_field = double(type: double(name: 'MetricStatType'))
      date_field = double(type: double(name: 'ISO8601DateTime'))
      metric_type = double(fields: {
        'activityScore' => stat_field,
        'renamedScore' => stat_field,
        'grimoireCreationDate' => date_field
      })

      aggregation = helper.generate_interval_aggs(
        metric_type, :grimoire_creation_date, '1M', 'StatType',
        { 'renamed_score' => 'original_score' }, ['_median', '_mean']
      )

      expect(aggregation.dig(:aggsWithDate, :aggs)).to eq(
        'activity_score_median' => { avg: { field: 'activity_score_median' } },
        'activity_score_mean' => { avg: { field: 'activity_score_mean' } },
        'renamed_score_median' => { avg: { field: 'original_score_median' } },
        'renamed_score_mean' => { avg: { field: 'original_score_mean' } }
      )
    end
  end
end
