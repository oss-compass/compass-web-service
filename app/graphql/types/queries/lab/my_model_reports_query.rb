# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class MyModelReportsQuery < BaseQuery
        include Pagy::Backend

        type Types::Lab::MyReportType, null: true

        description 'Get report data of my lab models'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(page: 1, per: 5)
          current_user = context[:current_user]
          login_required!(current_user)

          models = current_user.lab_models_has_participated_in

          model_ids = models.pluck(:id)

          # pagyer, records = pagy(LabModelVersion
          #                          .joins(:lab_model)
          #                          .joins(:lab_model_reports)
          #                          .where(lab_model_id: model_ids)
          #                          .select('lab_model_versions.*, lab_model_versions.id as versionId,  lab_models.name AS modelName,lab_models.id as modelId'),
          #                        { page: page, items: per })

          pagyer, records = pagy(LabModelReport
                                   .joins(:lab_model)
                                   .joins(:lab_model_version)
                                   .where(user_id: current_user.id)
                                   .select('lab_model_versions.*, lab_model_versions.id as versionId, lab_model_reports.id as reportId, lab_models.name AS modelName,lab_models.id as modelId,lab_model_reports.*')
                                   .order('lab_model_reports.created_at DESC'),
                                 { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
        end
      end
    end
  end
end
