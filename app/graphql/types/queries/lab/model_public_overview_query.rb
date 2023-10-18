# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ModelPublicOverviewQuery < BaseQuery
        include Pagy::Backend

        type Types::Lab::ModelPublicPageType, null: true
        description 'Get public lab model data of OSS Compass'
        argument :sort, String, required: false, description: 'the field to sort by, `default: created_at`'
        argument :direction, String, required: false, description: 'the direction to sort, `default: desc`'
        argument :page, Integer, required: false, description: 'page number, `default: 1`'
        argument :per, Integer, required: false, description: 'per page number, `default: 9`'

        def resolve(sort: 'updated_at', direction: 'desc', page: 1, per: 9)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if per > 20

          models = LabModel.where(is_public: true).includes([:mainline_version])
          models = models.order(sort => direction) if LabModel.sortable_fields.include?(sort) && LabModel.sortable_directions.include?(direction)

          pagyer, records = pagy(models, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
        end
      end
    end
  end
end
