# frozen_string_literal: true
module Types
  module Queries
    class SubjectSubscriptionCountQuery < BaseQuery
      type Types::Subscription::SubjectSubscriptionCountType, null: false

      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: true, description: 'repo or project level(repo/community)'

      def resolve(label: nil, level: nil)
        subject = Subject.find_by(label: label, level: level)
        return { count: 0, subscribed: false } unless subject

        count = subject.subscriptions.count
        current_user = context[:current_user]
        subscribed = current_user ? current_user.subscriptions.where(subject_id: subject.id).exists? : false
        { count: count, subscribed: subscribed }
      end
    end
  end
end
