# frozen_string_literal: true

require 'rails_helper' unless defined?(CompassUtils)

RSpec.describe CompassUtils do
  describe '#extract_date' do
    let(:helper) { Object.new.extend(described_class) }
    let(:today) { Date.new(2026, 10, 8).end_of_day }
    let(:default_range) { [today - 3.months, today, false] }

    before do
      allow(Date).to receive(:today).and_return(Date.new(2026, 10, 8))
    end

    it 'falls back for a DateTime range a fraction of a second short of seven days' do
      first = DateTime.iso8601('2024-01-01T00:00:00.25Z')
      last = DateTime.iso8601('2024-01-08T00:00:00Z')

      expect(helper.extract_date(first, last)).to eq(default_range)
    end

    it 'uses monthly aggregation just beyond the DateTime duration threshold' do
      first = DateTime.iso8601('2024-01-01T00:00:00.25Z')
      last = DateTime.iso8601('2025-12-21T00:00:00.50Z')

      expect(helper.extract_date(first, last)).to eq([first, last, '1M'])
    end

    it 'falls back for a Time range a fraction of a second short of seven days' do
      first = Time.iso8601('2024-01-01T00:00:00.25Z')
      last = Time.iso8601('2024-01-08T00:00:00Z')

      expect(helper.extract_date(first, last)).to eq(default_range)
    end

    it 'uses monthly aggregation just beyond the Time duration threshold' do
      first = Time.iso8601('2024-01-01T00:00:00.25Z')
      last = Time.iso8601('2025-12-21T00:00:00.50Z')

      expect(helper.extract_date(first, last)).to eq([first, last, '1M'])
    end

    it 'preserves a range of exactly seven days with fractional DateTime endpoints' do
      first = DateTime.iso8601('2024-01-01T08:00:00.25+08:00')
      last = DateTime.iso8601('2024-01-08T05:30:00.25+05:30')

      expect(helper.extract_date(first, last)).to eq([first, last, false])
    end

    it 'preserves the inclusive non-monthly threshold with fractional endpoints' do
      first = DateTime.iso8601('2024-01-01T00:00:00.25Z')
      last = DateTime.iso8601('2025-12-21T00:00:00.25Z')

      expect(helper.extract_date(first, last)).to eq([first, last, false])
    end

    it 'preserves the documented date-only DateTime input shape at seven days' do
      first = DateTime.parse('2024-01-01')
      last = DateTime.parse('2024-01-08')

      expect(helper.extract_date(first, last)).to eq([first, last, false])
    end

    it 'keeps monthly aggregation for an integer-second range above the threshold' do
      first = Time.iso8601('2024-01-01T00:00:00Z')
      last = Time.iso8601('2025-12-21T00:00:01Z')

      expect(helper.extract_date(first, last)).to eq([first, last, '1M'])
    end

    it 'keeps the fallback for a short integer-second range' do
      first = Time.iso8601('2024-01-01T00:00:00Z')
      last = Time.iso8601('2024-01-07T23:59:59Z')

      expect(helper.extract_date(first, last)).to eq(default_range)
    end

    it 'keeps the default range when both dates are omitted' do
      expect(helper.extract_date(nil, nil)).to eq(default_range)
    end

    it 'keeps the existing cap on future end dates' do
      first = DateTime.iso8601('2026-01-01T00:00:00Z')
      last = DateTime.iso8601('2027-01-01T00:00:00Z')

      expect(helper.extract_date(first, last)).to eq([first, today, false])
    end

    it 'compares instants for mixed Time and DateTime endpoints with different offsets' do
      first = DateTime.iso8601('2024-01-01T08:00:00.25+08:00')
      last = Time.iso8601('2025-12-21T05:30:00.50+05:30')

      expect(helper.extract_date(first, last)).to eq([first, last, '1M'])
    end
  end
end
