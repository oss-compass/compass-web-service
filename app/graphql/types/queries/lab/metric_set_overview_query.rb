# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class MetricSetOverviewQuery < BaseQuery

        type [Types::Lab::ModelMetricType], null: true
        description 'Get overview data of metrics set on compass lab'

        def resolve()
          current_user = context[:current_user]
          raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

          ::LabMetric.all
        end
      end
    end
  end
end
