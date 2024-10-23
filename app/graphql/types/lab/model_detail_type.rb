# frozen_string_literal: true

module Types
  module Lab
    class ModelDetailType < Types::BaseObject
      field :id, Integer, null: false
      field :name, String, null: false
      field :description, String
      field :is_public, Boolean, null: false
      field :user_id, Integer, null: false
      field :default_version, ModelVersionType
      field :latest_versions, [ModelVersionType], description: 'Details of the 1000 latest updates'
      field :trigger_remaining_count, Integer, null: false
      field :permissions, PermissionType
      field :reference_count, Integer ,description: 'Reference count of the model'
      field :loginBinds, Types::LoginBindType
      field :created_at, GraphQL::Types::ISO8601DateTime

      def name
        object.name_after_reviewed
      end

      def permissions
        context[:current_user].my_member_permission_of(object)
      end

      def loginBinds
        LoginBind.find_by(user_id: model.user_id)
      end

      def model
        @model ||= object
      end
    end
  end
end
