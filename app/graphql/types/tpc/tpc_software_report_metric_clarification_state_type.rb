# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricClarificationStateType < Types::BaseObject
      field :id, Integer, null: false
      field :metric_name, String
      field :state, Integer, description: '1: accept, 0: reject'
      field :user_id, Integer, null: false
      field :user, Types::UserType
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      def user
        User.find_by(id: object.user_id)
      end

    end
  end
end
