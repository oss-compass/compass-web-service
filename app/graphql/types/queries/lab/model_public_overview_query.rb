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
        argument :metric_id, Integer, required: false, description: 'metric_id'
        argument :model_type, Integer, required: false, description: 'model_type 0:personal,1:chaoss'

        def resolve(sort: 'updated_at', direction: 'desc', page: 1, per: 9, metric_id: nil, model_type: nil)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if per > 20
          models = nil
          if metric_id.present?
            lab_model_ids = LabModelMetric
                              .joins(:lab_model_version)
                              .where(lab_metric_id: metric_id)
                              .select(:lab_model_id)
                              .distinct
            models = LabModel.where(is_public: true, id: lab_model_ids).includes([:mainline_version])
          else
            models = LabModel.where(is_public: true).includes([:mainline_version])
          end
          models = models.where(model_type: model_type) if model_type.present?
          models = models.order(sort => direction) if LabModel.sortable_fields.include?(sort) && LabModel.sortable_directions.include?(direction)

          pagyer, records = pagy(models, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
        end
      end
    end
  end
end
