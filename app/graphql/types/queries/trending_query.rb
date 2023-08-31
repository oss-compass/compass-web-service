# frozen_string_literal: true

module Types
  module Queries
    class TrendingQuery < BaseQuery
      TRENDING_CACHE_KEY = 'compass-trending'

      type [Types::TrendingType], null: false
      description 'Get trending data of compass'
      argument :level, String, required: false, description: 'filter by level (repo/community) default: repo'

      def resolve(level: 'repo')
        return [] unless ['repo', 'community'].include?(level)

        Rails.cache.fetch("#{TRENDING_CACHE_KEY}-#{level}", expires_in: 2.hours) do
          top_activity_for_trending =
            if level == 'community'
              fetch_top_activity_by_phrase(level, nil)
            else
              fetch_top_activity_by_phrase(level, 'gitee.com') + fetch_top_activity_by_phrase(level, 'github.com')
            end

          activity_upward_trending = fetch_top_activity_upward_trending(level)
          candidate_set = activity_upward_trending + top_activity_for_trending
          candidates_labels = candidate_set.map { |set| set[:label] }
          after_filter_labels = filter_by_other_metric_models(candidates_labels, level)

          trendings = []
          candidate_set.each do |set|
            if after_filter_labels.include?(set[:label])
              repos_count = extract_repos_count(set[:label], set[:level])
              origin = extract_repos_source(set[:label], set[:level])
              name, full_path = extract_name_and_full_path(set[:label])
              collections = set[:level] == 'repo' ? BaseCollection.collections_of(set[:label]) : []
              trendings << OpenStruct.new(
                {
                  name: name,
                  origin: origin,
                  label: set[:label],
                  level: set[:level],
                  short_code: ShortenedLabel.convert(set[:label], set[:level]),
                  full_path: full_path,
                  collections: collections,
                  activity_score: set[:activity_score],
                  repos_count: repos_count,
                }
              )
            end
          end
          trendings.uniq{ |row| row.label }
        end.sample(10)
      end

      def fetch_top_activity_by_phrase(level, domain, limit: 50)
        basic =
          ActivityMetric
            .where(level: level)
            .custom(collapse: { field: 'label.keyword' })

        basic = basic.must(match_phrase: { 'label': domain }) if domain

        basic
          .range(:grimoire_creation_date, gte: Date.today.end_of_day - 1.month, lte: Date.today.end_of_day)
          .page(1)
          .per(limit)
          .sort(activity_score: :desc)
          .source(['label', 'activity_score'])
          .execute
          .raw_response['hits']['hits'].map do |row|
          {
            label: row['_source']['label'],
            level: level,
            activity_score: row['_source']['activity_score']
          }
        end
      end

      def fetch_top_activity_upward_trending(level, limit: 50)
        ActivityMetric
          .where(level: level)
          .range(:grimoire_creation_date, gte: Date.today.end_of_day - 1.month, lte: Date.today.end_of_day)
          .sort(grimoire_creation_date: :desc)
          .per(0)
          .aggregate(
            {
              label_group: {
                terms: {
                  field: "label.keyword",
                  size: limit
                },
                aggs: {
                  arise: {
                    date_histogram: {
                      field: :grimoire_creation_date,
                      interval: "week",
                    },
                    aggs: {
                      avg_activity: {
                        avg: {
                          field: "activity_score"
                        }
                      },
                      the_delta: {
                        derivative: {
                          buckets_path: "avg_activity"
                        }
                      }
                    }
                  }
                }
              }
            })
          .execute
          .aggregations&.[]('label_group')&.[]('buckets')
          .select { |row| row['arise']['buckets'].last&.[]('the_delta')&.[]('value').to_f > 0.001 }
          .map do |row|
          {
            label: row['key'],
            level: level,
            activity_score: row['arise']['buckets'].last&.[]('avg_activity')&.[]('value').to_f
          } || []
        end
      end

      def filter_by_other_metric_models(candidate_labels, level)
        return candidate_labels if level == 'community' || candidate_labels.blank?
        { community_support_score: CommunityMetric, code_quality_guarantee: CodequalityMetric }.map do |score, metric|
          metric
            .where(level: level)
            .where({'label.keyword' => candidate_labels})
            .range(:grimoire_creation_date, gte: Date.today.end_of_day - 1.month, lte: Date.today.end_of_day)
            .per(0)
            .aggregate(
              {
                label_group: {
                  terms: {
                    field: "label.keyword",
                    size: candidate_labels.length
                  },
                  aggs: {
                    avg_score: {
                      avg: {
                        field: score
                      }
                    }
                  }
                }
              })
            .execute
            .aggregations&.[]('label_group')&.[]('buckets')
            .select { |row| row['avg_score']&.[]('value').to_f > 0.0 }
            .map { |row| row['key'] }
        end.reduce(&:&) || []
      end
    end
  end
end
