module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    field :message, String, null: true, camelize: false
    field :errors, [Types::ErrorType],
          null: true,
          description: 'Errors encountered during execution of the mutation.'

    def login_required!(current_user)
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?
    end

    def validate_tpc!(current_user)
      login_required!(current_user)
      return if current_user&.is_tpc?
      raise GraphQL::ExecutionError.new I18n.t('users.forbidden')
    end

    def validate_admin!(current_user)
      login_required!(current_user)
      return if current_user&.is_admin?
      raise GraphQL::ExecutionError.new I18n.t('users.forbidden')
    end

    def validate_repo_admin!(current_user, label, level)
      login_required!(current_user)
      return if current_user&.is_admin?
      return if current_user&.has_privilege_to?(label, level)
      raise GraphQL::ExecutionError.new I18n.t('users.forbidden')
    end

  end
end
