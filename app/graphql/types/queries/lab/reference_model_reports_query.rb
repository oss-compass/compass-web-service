# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ReferenceModelReportsQuery < BaseQuery
        include Pagy::Backend

        type Types::Lab::MyReportType, null: true

        description 'Get report data of the lab model'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'
        argument :model_id, Integer, required: true, description: 'lab model id'

        def resolve(page: 1, per: 5, model_id: nil)
          current_user = context[:current_user]
          login_required!(current_user)
          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

          pagyer, records = pagy(LabModelReport
                                   .joins(:lab_model)
                                   .joins(:lab_model_version)
                                   .where(lab_model_id: model.id, is_public: true)
                                   .or(LabModelReport.where(lab_model_id: model.parent_model_id, is_public: true))
                                   .select('lab_model_versions.id as versionId, lab_model_versions.version,
lab_model_reports.id as reportId, lab_models.name AS modelName,lab_models.id as modelId, lab_models.parent_model_id,
lab_model_reports.*')
                                   .order('lab_model_reports.created_at DESC'),
                                 { page: page, items: per })

          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
        end
      end
    end
  end
end
