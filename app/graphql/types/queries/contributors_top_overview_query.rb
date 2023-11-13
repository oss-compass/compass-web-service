# frozen_string_literal: true

module Types
  module Queries
    class ContributorsTopOverviewQuery < BaseQuery

      MAX_CONTRIBUTORS = 100

      attr_accessor :indexer, :repo_urls, :begin_date, :end_date, :origin

      type [Types::Meta::ContributorTopOverviewType], null: false

      description 'Get top N percentage contributors overview'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project level', default_value: 'repo'
      argument :limit, Integer, required: false, description: 'Limitations on the number of contributors, default: 10'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', limit: 10, filter_opts: [], begin_date: nil, end_date: nil)
        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        if limit > 20 || limit < 1
          raise GraphQL::ExecutionError.new I18n.t('basic.invalid_range', param: 'limit', max: '20', min: 1)
        end

        @begin_date, @end_date, interval = extract_date(begin_date, end_date)

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

        resp =
          contributor_base
            .aggregate(
              {
                top_overview: {
                  terms: {
                    field: 'ecological_type.keyword',
                    size: 4
                  },
                  aggs: {
                    top_contributor_hits: {
                      top_hits: {
                        size: MAX_CONTRIBUTORS,
                        sort: [{contribution: {order: 'desc'}}]
                      }
                    }
                  }
                }
              }
            )
            .per(0)
            .execute
            .raw_response

        total_count = resp.dig('hits', 'total', 'value')

        resp
          .dig('aggregations', 'top_overview', 'buckets')
          .map { |bucket| build_distribution(bucket, total_count, limit) }
      end

      def build_distribution(bucket, total, limit)
        sub_total = bucket['doc_count']
        ecological_type = bucket['key']
        top_contributor_hits = bucket.dig('top_contributor_hits', 'hits', 'hits')

        top_contributor_distribution =
          top_contributor_hits.reduce({}) do |acc, hit|
          data = hit['_source']
          key = data['contributor']
          if acc.key?(key)
            acc[key][:sub_count] += 1
            acc[key][:sub_ratio] = sub_total == 0 ? 0 : (acc[key][:sub_count].to_f / sub_total.to_f)
          else
            acc[key] = {
              sub_count: 1,
              sub_ratio: sub_total == 0 ? 0 : (data['doc_count'].to_f / sub_total.to_f),
              sub_name: data['contributor'],
              total_count: total
            }
          end
          acc
        end
        .sort_by { |_, h| -h[:sub_count].to_i }
        .map{ |_, v| v }
        .first(limit)

        other_contributors_count =
          sub_total - top_contributor_distribution.sum { |h| h[:sub_count] }

        top_contributor_distribution << {
          sub_count: other_contributors_count,
          sub_ratio: sub_total == 0 ? 0 : (other_contributors_count.to_f / sub_total.to_f),
          sub_name: 'other',
          total_count: total
        }

        {
          ecological_type: ecological_type,
          ecological_type_percentage: sub_total.to_f / total,
          top_contributor_distribution: top_contributor_distribution
        }
      end
    end
  end
end
