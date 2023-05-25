# frozen_string_literal: true
module Mutations
  class CreateSubscription < BaseMutation
    include Director

    field :status, String, null: false
    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: true, description: 'repo or project level(repo/community)'

    def resolve(label: nil, level: nil)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      label = normalize_label(label)

      subject = Subject.find_by(label: label)
      if subject.present?
        subscription = current_user.subscriptions.find_by(subject: subject)
        raise GraphQL::ExecutionError.new I18n.t('users.subscription_already_exist') if subscription.present?

        current_user.subscriptions.create(subject: subject)
        return { status: true }
      end

      subscription = current_user.subscriptions.joins(:subject).find_by(subjects: { label: label })
      raise GraphQL::ExecutionError.new I18n.t('users.subscription_already_exist') if subscription.present?

      task = ProjectTask.find_by(project_name: label)
      task ||= ProjectTask.find_by(remote_url: label)
      if task.blank?
        existed_metrics = [ActivityMetric, CommunityMetric, CodequalityMetric, GroupActivityMetric].map do |metric|
          result = metric.query_label_one(label, level)
          hits = result&.[]('hits')&.[]('hits')
          hits.present? ? hits.first['_source'] : nil
        end
        raise GraphQL::ExecutionError.new I18n.t('users.subject_not_exist') unless existed_metrics.any?

        status_updated_at = existed_metrics.first['metadata__enriched_on']
        status = Subject::COMPLETE
      else
        status_updated_at = task.updated_at
        status = Subject.task_status_converter(task.status)
      end

      count = (level == 'repo' || task.blank?) ? 1 : director_repo_list_with_type(task.remote_url).length

      subject = Subject.create(
        label: label,
        level: level,
        status: status,
        status_updated_at: status_updated_at,
        count: count
      )
      current_user.subscriptions.create(subject: subject)
      { status: true }
    end
  end
end
