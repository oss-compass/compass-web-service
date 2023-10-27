# frozen_string_literal: true

module Types
  module Queries
    class ContributorsDetailOverviewQuery < BaseQuery

      attr_accessor :indexer, :repo_urls, :begin_date, :end_date, :origin

      type Types::Meta::ContributorDetailOverviewType, null: false
      description 'Get overview data of a contributor detail'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'

      def resolve(label: nil, level: 'repo')
        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        @begin_date, @end_date, interval = extract_date(nil, nil)

        @indexer, @repo_urls, @origin =
                              select_idx_repos_by_lablel_and_level(
                                label,
                                level,
                                GiteeContributorEnrich,
                                GithubContributorEnrich
                              )
        all_contribution = contributing_percentage_of(label, level, 'all')
        org_managers_contribution = contributing_percentage_of(label, level, 'organization manager')
        individual_participants_contribution = contributing_percentage_of(label, level, 'individual participant')

        {
          top_contributing_individual: top_contributing_of(label, level, 'individual'),
          top_contributing_organization: top_contributing_of(label, level, 'orgranization'),
          individual_participants_contribution_ratio: (individual_participants_contribution / all_contribution).round(2),
          organization_managers_contribution_ratio: (org_managers_contribution / all_contribution).round(2)
        }
      end

      def top_contributing_of(label, level, contributor_type)
        resp = indexer
                 .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                 .must(match_phrase: {ecological_type: contributor_type})
                 .where(is_bot: false)
                 .must(terms: { 'repo_name.keyword': repo_urls })
                 .aggregate(
                   {
                     count_of_uuid: {
                       terms: { field: 'contributor.keyword' },
                       aggs: {
                         sum_contribution: {
                           sum: {
                             field: 'contribution'
                           }
                         }
                       }
                     },
                     max_contribution: {
                       max_bucket: {
                         buckets_path: 'count_of_uuid>sum_contribution'
                       }
                     }
                   }
                 )
                 .per(0)
                 .execute
                 .aggregations
                 .fetch('max_contribution')
        { name: resp['keys'].first, type: 'orgranization', value: resp['value'], origin: origin }
      end

      def contributing_percentage_of(label, level, contributor_type)
        base = indexer
                 .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
        if contributor_type != 'all'
          base = base
            .must(match_phrase: {ecological_type: contributor_type})
            .where(is_bot: false)
        end
        base
          .must(terms: { 'repo_name.keyword': repo_urls })
          .aggregate({ count: { sum: { field: 'contribution' } } })
          .per(0)
          .execute
          .aggregations
          .dig('count', 'value')
      end
    end
  end
end
