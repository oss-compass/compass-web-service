# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class MemberOverviewQuery < BaseQuery
        include Pagy::Backend

        type Types::Lab::MemberPageType, null: true
        description 'Get members data of a lab model'
        argument :model_id, Integer, required: false, description: 'lab mode id'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(model_id: nil, page: 1, per: 9)
          current_user = context[:current_user]
          raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

          raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if per > 20

          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

          raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).read?

          pagyer, records = pagy(model.members, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records, model: model}
        end
      end
    end
  end
end
