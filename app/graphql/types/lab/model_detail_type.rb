# frozen_string_literal: true

module Types
  module Lab
    class ModelDetailType < Types::BaseObject
      field :id, Integer, null: false
      field :name, String, null: false
      field :dimension, Integer, null: false
      field :is_public, Boolean, null: false
      field :is_general, Boolean, null: false
      field :user_id, Integer, null: false
      field :default_version, ModelVersionType
      field :latest_versions, [ModelVersionType], description: 'Details of the 1000 latest updates'
      field :trigger_remaining_count, Integer, null: false

      field :permissions, PermissionType

      def name
        object.name_after_reviewed
      end

      def permissions
        context[:current_user].my_member_permission_of(object)
      end
    end
  end
end
