# frozen_string_literal: true

module Mutations
  class CreateLabModelComment < BaseMutation
    field :data, Types::Lab::ModelCommentType, null: true

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :version_id, Integer, required: false, description: 'lab model version id'
    argument :model_metric_id, Integer, required: false, description: 'lab model metric id'
    argument :reply_to, Integer, required: false, description: 'reply to comment id'
    argument :content, String, required: true, description: 'comment content'
    argument :images, [Input::Base64ImageInput], required: false,  description: 'related images under this comment'

    def resolve(
          model_id: nil,
          version_id: nil,
          model_metric_id: nil,
          reply_to: nil,
          content: nil,
          images: []
        )

      current_user = context[:current_user]

      login_required!(current_user)

      raise GraphQL::ExecutionError.new I18n.t('lab_models.content_required') if content.strip.blank?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if images.length > 5

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?

      create_set = {
        user: current_user,
        content: content
      }

      model_version = nil
      if version_id.present?
        model_version = model.versions.find_by(id: version_id)
        create_set[:lab_model_version] = model_version if model_version.present?
      end

      model_metric = nil
      if model_metric_id.present?
        raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model_version.present?
        model_metric = model_version.metrics.find_by(id: model_metric_id)
        create_set[:lab_model_metric] = model_metric if model_metric.present?
      end

      reply = nil
      if reply_to.present?
        reply = model.comments.find_by(id: reply_to)
        create_set[:reply_to] = reply.id if reply.present?
      end

      comment = model.comments.create(create_set)
      images.each do |image|
        comment.images.attach(data: image.base64, filename: image.filename)
      end
      comment.save!


      { data: comment }
    end
  end
end
