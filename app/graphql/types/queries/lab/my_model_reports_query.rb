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

          pagyer, records = pagy(LabModelReport
                                   .joins(:lab_model)
                                   .joins(:lab_model_version)
                                   .where(user_id: current_user.id)
                                   .select('lab_model_versions.id as version_id, lab_model_versions.version,
lab_model_reports.id as report_id, lab_models.name,lab_models.id as model_id, lab_models.parent_model_id,
lab_model_reports.*')
                                   .order('lab_model_reports.created_at DESC'),
                                 { page: page, items: per })

          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
        end
      end
    end
  end
end
