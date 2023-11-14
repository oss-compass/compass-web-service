module Types
  module Queries
    class BaseOverviewQuery < BaseQuery
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
    end
  end
end
