# frozen_string_literal: true


module Types
  module Queries
    class AnalysisStatusVerifyQuery < BaseQuery
      type ProjectCompletionRowType, null: false
      description 'repo or project analysis status (pending/progress/success/error/canceled/unsumbit)'
      argument :label, String, required: false, description: 'repo or project label'
      argument :short_code, String, required: false, description: 'repo or project short code'

      def resolve(label: nil, short_code: nil)
        label = ShortenedLabel.normalize_label(label) if label
        label = ShortenedLabel.revert(short_code)&.label if short_code

        result = {
          level: nil,
          label: label,
          status: ProjectTask::UnSubmit,
          updated_at: nil,
          short_code: short_code ? short_code : nil
        }

        return result unless label

        existed_metrics =
          [ActivityMetric, CommunityMetric, CodequalityMetric, GroupActivityMetric].map do |metric|
          metric.find_one('label', label)
        end.compact

        if metric = existed_metrics.first
          result[:status] = ProjectTask::Success
          result[:label] = metric['label']
          result[:level] = metric['level']
          result[:short_code] = ShortenedLabel.convert(metric['label'], metric['level'])
          result[:collections] = BaseCollection.collections_of(metric['label'], level: metric['level'])
          metadata__enriched_on = metric['metadata__enriched_on']
          result[:updated_at] = DateTime.parse(metadata__enriched_on).strftime rescue metadata__enriched_on
          return result
        end

        task = ProjectTask.find_by(project_name: label)
        task ||= ProjectTask.find_by(remote_url: label)

        if task.present?
          task_status =
            if task.level == 'repo'
              AnalyzeServer.new(repo_url: task.remote_url).check_task_status
            else
              AnalyzeGroupServer.new(yaml_url: task.remote_url).check_task_status
            end
          result[:label] = label
          result[:level] = task.level
          result[:status] = task_status
          result[:short_code] = ShortenedLabel.convert(label, task.level)
          result[:collections] = BaseCollection.collections_of(label, level: task.level)
          result[:updated_at] = task.updated_at
        end

        result
      end
    end
  end
end
