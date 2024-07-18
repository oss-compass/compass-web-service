# frozen_string_literal: true

module Mutations
  module Tpc
    class DeleteTpcSoftwareSelectionComment < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :comment_id, Integer, required: true

      def resolve(comment_id: nil)
        current_user = context[:current_user]
        login_required!(current_user)

        comment = TpcSoftwareComment.find_by(id: comment_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if comment.nil?
        raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || comment.user_id == current_user.id
        comment.destroy!

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
