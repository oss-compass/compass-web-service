# frozen_string_literal: true

module Types
  module Lab
    class PermissionType < Types::BaseObject
      field :can_read, Boolean, null: false
      field :can_update, Boolean, null: false
      field :can_execute, Boolean, null: false
      field :can_destroy, Boolean, null: false
    end
  end
end
