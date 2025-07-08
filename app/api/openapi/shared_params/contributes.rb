# frozen_string_literal: true
module Openapi
  module SharedParams
    module Contributes
      def get_sub_count_by_scope(contributors, scope)
        (scope == 'contributor' ? contributors.length : contributors.map { _1['contribution'] }.reduce(0, :+)).to_f
      end

      def build_org_dis_data(group, grouped_contributors, total_count, scope: 'contributor')

        sub_total = get_sub_count_by_scope(grouped_contributors, scope)

        top_contributor_distribution =
          if group.start_with?('organization')
            sub_grouped_contributors = grouped_contributors.group_by { _1['organization'] }
            sorted_group_contributors =
              if scope == 'contributor'
                sub_grouped_contributors.sort_by { |_k, v| -v.length }
              else
                sub_grouped_contributors.sort_by { |_k, v| -v.map { _1['contribution'] }.reduce(0, :+) }
              end
            top_group_contributors = sorted_group_contributors.first(10)
            top_group_contributors.map do |group, contributors|
              {
                subCount: get_sub_count_by_scope(contributors, scope),
                subRatio: total_count == 0 ? 0 : (get_sub_count_by_scope(contributors, scope) / total_count).round(4),
                subName: group,
                subBelong: group,
                totalCount: total_count
              }
            end
          else
            sorted_contributors = grouped_contributors.sort_by { -_1['contribution'] }
            top_contributors = sorted_contributors.first(10)
            top_contributors.map do |contributor|
              {
                subCount: get_sub_count_by_scope([contributor], scope),
                subRatio: total_count == 0 ? 0 : (get_sub_count_by_scope([contributor], scope) / total_count).round(4),
                subName: contributor['contributor'],
                subBelong: contributor['organization'],
                totalCount: total_count
              }
            end
          end

        other_contributors_count =
          sub_total - top_contributor_distribution.sum { |h| h[:subCount] }

        if other_contributors_count > 0
          top_contributor_distribution << {
            subCount: other_contributors_count,
            subRatio: total_count == 0 ? 0 : (other_contributors_count.to_f / total_count).round(4),
            subName: 'other',
            subBelong: 'other',
            totalCount: total_count
          }
        end

        {
          overviewName: 'Types::Queries::OrgContributorsDistributionQuery',
          subTypeName: group,
          subTypePercentage: sub_total == 0 ? 0 : (sub_total.to_f / total_count).round(4),
          topContributorDistribution: top_contributor_distribution
        }
      end
    end
  end
end
