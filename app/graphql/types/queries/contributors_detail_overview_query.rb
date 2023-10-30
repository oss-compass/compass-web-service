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

        contributor_base =
          indexer
            .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
            .where(is_bot: false)
            .must(terms: { 'repo_name.keyword': repo_urls })

        ecological_distribution = distribute_by_field(contributor_base, 'ecological_type.keyword', nil)
        organization_distribution = distribute_by_field(contributor_base, 'orgranization.keyword', nil)
        contributor_distribution = distribute_by_field(contributor_base, 'contributor.keyword', nil)

        {
          highest_contribution_contributor: top_contributing_of('individual'),
          highest_contribution_organization: top_contributing_of('orgranization', count_field: 'orgranization' ),
          org_all_count: org_all_count,
          contributor_all_count: contributor_all_count,
          ecological_distribution: ecological_distribution,
          organization_distribution: organization_distribution,
          contributor_distribution: contributor_distribution
        }
      end

      def top_contributing_of(contributor_type, count_field: 'contributor')
        resp = indexer
                 .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                 .must(match_phrase: {ecological_type: contributor_type})
                 .where(is_bot: false)
                 .must(terms: { 'repo_name.keyword': repo_urls })
                 .aggregate(
                   {
                     count_of_uuid: {
                       terms: { field: "#{count_field}.keyword" },
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

      def org_all_count
        count_of('orgranization')
      end

      def contributor_all_count
        count_of('contributor')
      end

      def count_of(contributor_type)
        indexer
          .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
          .must(terms: { 'repo_name.keyword': repo_urls })
          .aggregate({ count: { cardinality: { field: "#{contributor_type}.keyword" } }})
          .per(0)
          .execute
          .aggregations
          .dig('count', 'value')
      end
    end
  end
end
