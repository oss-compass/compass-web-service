# frozen_string_literal: true


module Types
  module Queries
    class AnalysisStatusQuery < BaseQuery
      type String, null: false
      description 'repo or project analysis status (pending/progress/success/error/canceled/unsumbit)'
      argument :label, String, required: true, description: 'repo or project label'

      def resolve(label: nil)
        existed_metrics =
          [ActivityMetric, CommunityMetric, CodequalityMetric].map do |metric|
          metric.exist_one?('label', label)
        end

        if existed_metrics.any?
          return ProjectTask::Success
        end

        label = (label =~ URI::regexp ? label : label.split('-').first rescue label)

        task = ProjectTask.find_by(project_name: label)
        task ||= ProjectTask.find_by(remote_url: label)
        if task.present?
          status =
            if task.level == 'repo'
              AnalyzeServer.new(repo_url: task.remote_url).check_task_status
            else
              AnalyzeGroupServer.new(yaml_url: task.remote_url).check_task_status
            end
          return status
        else
          return ProjectTask::UnSubmit
        end
      end
    end
  end
end
