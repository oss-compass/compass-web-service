# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetricModelsServer, '.new repo_type resolution' do
  it 'keeps an explicitly provided repo_type at repo level' do
    server = described_class.new(label: 'x', level: 'repo', repo_type: 'governance')

    expect(server.instance_variable_get(:@repo_type)).to eq('governance')
  end

  it 'defaults community level to software-artifact' do
    server = described_class.new(label: 'x', level: 'community')

    expect(server.instance_variable_get(:@repo_type)).to eq('software-artifact')
  end

  it 'leaves repo level without repo_type empty' do
    server = described_class.new(label: 'x', level: 'repo')

    expect(server.instance_variable_get(:@repo_type)).to be_nil
  end

  it 'keeps an explicit repo_type at community level' do
    server = described_class.new(label: 'x', level: 'community', repo_type: 'governance')

    expect(server.instance_variable_get(:@repo_type)).to eq('governance')
  end
end

RSpec.describe MetricModelsV2Server, '.new repo_type resolution' do
  it 'keeps an explicitly provided repo_type at repo level' do
    server = described_class.new(label: 'x', level: 'repo', repo_type: 'governance')

    expect(server.instance_variable_get(:@repo_type)).to eq('governance')
  end

  it 'defaults community level to software-artifact' do
    server = described_class.new(label: 'x', level: 'community')

    expect(server.instance_variable_get(:@repo_type)).to eq('software-artifact')
  end
end
