# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Queries::BaseOverviewQuery, '#build_org_distribution_data' do
  subject(:query) { described_class.new }

  let(:contributors) do
    [
      { 'contributor' => 'alice', 'organization' => 'org-big',   'contribution' => 100 },
      { 'contributor' => 'bob',   'organization' => 'org-big',   'contribution' => 50 },
      { 'contributor' => 'carol', 'organization' => 'org-small', 'contribution' => 1 }
    ]
  end

  it 'lists the most contributing organizations first' do
    result = query.build_org_distribution_data('organization_group', contributors, 3, scope: 'contribution')

    expect(result[:top_contributor_distribution].first[:sub_name]).to eq('org-big')
    expect(result[:top_contributor_distribution].last[:sub_name]).to eq('org-small')
  end

  it 'lists the organizations with most contributors first' do
    result = query.build_org_distribution_data('organization_group', contributors, 3, scope: 'contributor')

    expect(result[:top_contributor_distribution].first[:sub_name]).to eq('org-big')
  end

  it 'keeps the individual branch ordered by descending contribution' do
    result = query.build_org_distribution_data('individual_group', contributors, 3, scope: 'contribution')

    expect(result[:top_contributor_distribution].first[:sub_name]).to eq('alice')
  end
end
