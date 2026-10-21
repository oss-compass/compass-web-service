# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Queries::BaseOverviewQuery, type: :graphql do
  describe '#build_org_distribution_data' do
    let(:resolver) { described_class.new(object: nil, context: nil, field: nil) }

    # 12 个组织，成员数 1..12 递增；贡献者 scope 下 top 10 应为最大的十个组织。
    let(:contributors) do
      (1..12).flat_map do |org_index|
        Array.new(org_index) do |member_index|
          {
            'contributor' => "contributor-#{org_index}-#{member_index}",
            'organization' => "org-#{org_index}",
            'contribution' => 1
          }
        end
      end
    end

    it 'contributor scope 返回贡献者最多的十个组织（降序）' do
      result = resolver.build_org_distribution_data(
        'organization participant', contributors, contributors.length, scope: 'contributor'
      )
      names = result[:top_contributor_distribution].map { |entry| entry[:sub_name] }
      expect(names).to eq((3..12).map { |i| "org-#{i}" }.reverse)
      expect(names).not_to include('org-1', 'org-2')
    end

    it '非 contributor scope 按贡献总数降序（既有行为回归保护）' do
      result = resolver.build_org_distribution_data(
        'organization participant', contributors, contributors.length, scope: 'contribution'
      )
      names = result[:top_contributor_distribution].map { |entry| entry[:sub_name] }
      # 每个组织贡献总数均为成员数，降序 top 10 同为 org-12..org-3
      expect(names).to eq((3..12).map { |i| "org-#{i}" }.reverse)
    end
  end
end
