# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareCommentStateType < Types::BaseObject
      field :id, Integer, null: false
      field :metric_name, String
      field :state, Integer, description: 'reject: -1, accept: 1'
      field :member_type, Integer, description: 'committer: 0, sig lead: 1'
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
