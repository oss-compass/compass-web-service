# frozen_string_literal: true

module Mutations
  class UpdateLabModelComment < BaseMutation
    field :data, Types::Lab::ModelCommentType, null: true

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :comment_id, Integer, required: true, description: 'lab model comment id'
    argument :content, String, required: false, description: 'comment content'
    argument :images, [Input::Base64ImageInput], required: false,  description: 'related images under this comment'

    def resolve(model_id: nil, comment_id: nil, content: nil, images: [])

      current_user = context[:current_user]

      login_required!(current_user)

      raise GraphQL::ExecutionError.new I18n.t('lab_models.content_required') if content.strip.blank?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?

      comment = model.comments.find_by(id: comment_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless comment.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless current_user.id == comment.user_id
      if content.present?
        comment.update!(content: content)
      end

      new_images = images.select{ |image| !image.base64.starts_with?('/files') }
      keep_images = images.select{ |image| image.base64.starts_with?('/files') }.map(&:id).compact

      raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if keep_images.length + new_images.length > 5

      if keep_images.present?
        comment.images.where.not(id: keep_images).purge
      else
        comment.images.purge
      end

      if new_images.present?
        new_images.each do |image|
          comment.images.attach(data: image.base64, filename: image.filename)
        end
      end

      { data: comment }
    end
  end
end
