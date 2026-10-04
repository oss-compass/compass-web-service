# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CompassUtils#auto_break_line' do
  before do
    # The formatter needs no network, Rails application, or Director methods.
    # Restore both constants after each example, including in the full suite.
    stub_const('Director', Module.new)
    stub_const('CompassUtils', Module.new)
    load File.expand_path('../../app/controllers/concerns/compass_utils.rb', __dir__)
  end

  let(:formatter) { Class.new { include CompassUtils }.new }

  it 'does not insert a blank line before an unbroken Chinese description' do
    text = '统计项目在指定时间范围内的贡献者数量'
    expect(formatter.auto_break_line(text, max_length: 10)).to eq(text)
  end

  it 'counts the separator when extending a wrapped line' do
    expect(formatter.auto_break_line('first abc de', max_length: 5)).to eq("first\nabc\nde")
  end

  it 'keeps a line whose words and separator fit exactly' do
    expect(formatter.auto_break_line('one two three', max_length: 7)).to eq("one two\nthree")
  end

  it 'preserves long words without splitting them' do
    expect(formatter.auto_break_line('a verylongword b', max_length: 4)).to eq("a\nverylongword\nb")
  end

  it 'normalizes whitespace and handles empty captions' do
    expect(formatter.auto_break_line("  one   two  ", max_length: 20)).to eq('one two')
    expect(formatter.auto_break_line('')).to eq('')
  end
end
