# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSelectionCommentPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareCommentPageType, null: true
        description 'Get tpc software selection comment page'

        argument :selection_id, Integer, required: true
        argument :report_type, Integer, required: false, description: '0: selection 1:graduation', default_value: '0'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(selection_id: nil, report_type: 0, page: 1, per: 9)
          case report_type
          when TpcSoftwareMetricServer::Report_Type_Selection
            selection = TpcSoftwareSelection.find_by(id: selection_id)
            raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?
            metric_name = TpcSoftwareComment::Metric_Name_Selection
            tpc_software_type = TpcSoftwareComment::Type_Selection
          when TpcSoftwareMetricServer::Report_Type_Graduation
            selection = TpcSoftwareGraduation.find_by(id: selection_id)
            raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?
            metric_name = TpcSoftwareComment::Metric_Name_Graduation
            tpc_software_type = TpcSoftwareComment::Type_Graduation
          end

          items = TpcSoftwareComment.where("metric_name = ?", metric_name)
                                    .where("tpc_software_type = ?", tpc_software_type)
                                    .where("tpc_software_id = ?", selection.id)

          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
    end
  end
end
