# frozen_string_literal

module Types
  module Queries
    class LatestMetricsQuery < BaseQuery
      type Types::LatestMetricsType, null: false
      description 'Get latest metrics data of the specified label'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'

      def resolve(label: nil, level: 'repo')
        label = normalize_label(label)
        origin = extract_repos_source(label, level)
        repos_count = extract_repos_count(label, level)
        reference_url = extract_label_reference(label, level)

        result = {}
        [ActivityMetric, CommunityMetric, CodequalityMetric, GroupActivityMetric].map do |metric|
          extract_metric(metric, label, level, result)
        end
        keys = Types::LatestMetricsType.fields.keys
        skeleton = Hash[keys.zip([])].symbolize_keys
        skeleton = skeleton.merge(Hash[keys.map(&:underscore).zip([])].symbolize_keys)
        skeleton['origin'] = origin
        skeleton['repos_count'] = repos_count
        skeleton['reference_url'] = reference_url
        OpenStruct.new(skeleton.merge(result))
      end

      def extract_metric(metric_model, label, level, result)
        resp = metric_model.query_label_one(label, level)
        metrics =
          build_metrics_data(resp, "Types::#{metric_model}Type".constantize) do |skeleton, raw|
          skeleton.merge(raw)
        end
        case metrics&.first&.symbolize_keys
            in { activity_score: score, grimoire_creation_date: date, label: label, level: level }
            result[:label] = label
            result[:level] = level
            result[:activity_score] = score
            result[:activity_score_updated_at] = date
            in { community_support_score: score, grimoire_creation_date: date, label: label, level: level }
            result[:label] = label
            result[:level] = level
            result[:community_support_score] = score
            result[:community_support_score_updated_at] = date
            in { code_quality_guarantee: score, grimoire_creation_date: date, label: label, level: level }
            result[:label] = label
            result[:level] = level
            result[:code_quality_guarantee] = score
            result[:code_quality_guarantee_updated_at] = date
            in { organizations_activity: score, grimoire_creation_date: date, label: label, level: level }
            result[:label] = label
            result[:level] = level
            result[:organizations_activity] = score
            result[:organizations_activity_updated_at] = date
        else
        end
      end
    end
  end
end
