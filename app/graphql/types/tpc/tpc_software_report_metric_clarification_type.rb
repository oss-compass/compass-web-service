# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricClarificationType < Types::BaseObject
      field :id, Integer, null: false
      field :user_id, String
      field :user, Types::UserType
      field :metric_name, String
      field :content, String
      field :created_at, GraphQL::Types::ISO8601DateTime
      field :updated_at, GraphQL::Types::ISO8601DateTime

      def user
        User.find_by(id: object.user_id)
      end
    end
  end
end
