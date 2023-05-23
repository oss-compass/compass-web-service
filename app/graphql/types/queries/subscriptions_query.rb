# frozen_string_literal: true
module Types
  module Queries
    class SubscriptionsQuery < BaseQuery

      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: true, description: 'repo or project level(repo/community)'

      def resolve(label: nil, level: nil)
        subscriptions = object.subscriptions.order(id: :desc)
        subscriptions = subscriptions.where(subject: Subject.find_by(label: label)) if label.present?
        subscriptions = subscriptions.where(subject: Subject.where(level: level)) if level.present?
        subscriptions
      end
    end
  end
end
