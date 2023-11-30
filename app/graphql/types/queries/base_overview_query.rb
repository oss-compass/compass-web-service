module Types
  module Queries
    class BaseOverviewQuery < BaseQuery
      def build_org_distribution_data(group, grouped_contributors, total_count, scope: 'contributor')

        sub_total = get_sub_count_by_scope(grouped_contributors, scope)

        top_contributor_distribution =
          if group.start_with?('organization')
            sub_grouped_contributors = grouped_contributors.group_by { _1['organization'] }
            sorted_group_contributors =
              if scope == 'contributor'
                sub_grouped_contributors.sort_by { |_k, v| v.length }
              else
                sub_grouped_contributors.sort_by { |_k, v| v.map { _1['contribution'] }.reduce(0, :+) }
              end
            top_group_contributors = sorted_group_contributors.first(10)
            top_group_contributors.map do |group, contributors|
              {
                sub_count: get_sub_count_by_scope(contributors, scope),
                sub_ratio: total_count == 0 ? 0 : (get_sub_count_by_scope(contributors, scope) / total_count).round(4),
                sub_name: group,
                sub_belong: group,
                total_count: total_count
              }
            end
          else
            sorted_contributors = grouped_contributors.sort_by { -_1['contribution'] }
            top_contributors = sorted_contributors.first(10)
            top_contributors.map do |contributor|
              {
                sub_count: get_sub_count_by_scope([contributor], scope),
                sub_ratio: total_count == 0 ? 0 : (get_sub_count_by_scope([contributor], scope) / total_count).round(4),
                sub_name: contributor['contributor'],
                sub_belong: contributor['organization'],
                total_count: total_count
              }
            end
          end

        other_contributors_count =
          sub_total - top_contributor_distribution.sum { |h| h[:sub_count] }

        if other_contributors_count > 0
          top_contributor_distribution << {
            sub_count: other_contributors_count,
            sub_ratio: total_count == 0 ? 0 : (other_contributors_count.to_f / total_count).round(4),
            sub_name: 'other',
            sub_belong: 'other',
            total_count: total_count
          }
        end

        {
          overview_name: self.class.name,
          sub_type_name: group,
          sub_type_percentage: sub_total == 0 ? 0 : (sub_total.to_f / total_count).round(4),
          top_contributor_distribution: top_contributor_distribution
        }
      end

      def build_distribution_data(group, grouped_contributors, total_count)
        sub_total = grouped_contributors.map { _1['contribution'] }.reduce(0, :+)
        sorted_contributors = grouped_contributors.sort_by { -_1['contribution'] }
        top_contributors = sorted_contributors.first(10)
        top_contributor_distribution =
          top_contributors.map do |contributor|
          {
            sub_count: contributor['contribution'],
            sub_ratio: total_count == 0 ? 0 : (contributor['contribution'].to_f / total_count).round(4),
            sub_name: contributor['contributor'],
            sub_belong: contributor['organization'],
            total_count: total_count
          }
        end

        other_contributors_count =
          sub_total - top_contributor_distribution.sum { |h| h[:sub_count] }

        if other_contributors_count > 0
          top_contributor_distribution << {
            sub_count: other_contributors_count,
            sub_ratio: total_count == 0 ? 0 : (other_contributors_count.to_f / total_count).round(4),
            sub_name: 'other',
            sub_belong: 'other',
            total_count: total_count
          }
        end

        {
          overview_name: self.class.name,
          sub_type_name: group,
          sub_type_percentage: sub_total == 0 ? 0 : (sub_total.to_f / total_count).round(4),
          top_contributor_distribution: top_contributor_distribution
        }
      end

      private

      def get_sub_count_by_scope(contributors, scope)
        (scope == 'contributor' ? contributors.length : contributors.map { _1['contribution'] }.reduce(0, :+)).to_f
      end
    end
  end
end
