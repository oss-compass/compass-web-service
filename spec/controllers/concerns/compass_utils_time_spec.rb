# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompassUtils do
  describe '#time_diff_hours' do
    it 'reports elapsed time in hours for code-check responses' do
      helper = Object.new.extend(described_class)

      expect(helper.time_diff_hours('2026-09-23T10:00:00Z', '2026-09-23T12:30:00Z')).to eq('2.50')
      expect(helper.time_diff_hours('2026-09-23T10:00:00Z', '2026-09-24T10:00:00Z')).to eq('24.00')
    end
  end
end
