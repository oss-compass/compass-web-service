# frozen_string_literal: true
module Types
  module Queries
    class SubscriptionsQuery < BaseQuery
      include Pagy::Backend

      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'
      argument :label, String, required: false, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project level(repo/community)'

      def resolve(page: 1, per: 10, label: nil, level: nil)
        subscriptions = object.subscriptions.order(id: :desc)
        subscriptions = subscriptions.where(subject: Subject.find_by(label: label)) if label.present?
        subscriptions = subscriptions.where(subject: Subject.where(level: level)) if level.present?
        pagyer, records = pagy(subscriptions, { page: page, items: per })
        { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
      end
    end
  end
end
