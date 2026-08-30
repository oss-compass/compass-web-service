# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommunityPopularityMetric do
  it 'groups under the community vitality dimension, like its sibling metrics' do
    expect(described_class.dimension).to eq('community vitality')
    expect(described_class.dimension).to eq(DeveloperBaseMetric.dimension)
    expect(described_class.dimension).to eq(ContributionActivityMetric.dimension)
  end

  it 'stays in the community_health scope' do
    expect(described_class.scope).to eq('community_health')
  end
end
