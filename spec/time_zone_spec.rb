# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'application time zone' do
  it 'keeps Time.current independent of the host process timezone' do
    original_tz = ENV['TZ']
    ENV['TZ'] = 'Asia/Shanghai'

    expect(Rails.application.config.time_zone).to eq('UTC')
    expect(Time.zone.name).to eq('UTC')
    expect(Time.current.utc_offset).to eq(0)
  ensure
    ENV['TZ'] = original_tz
  end
end
