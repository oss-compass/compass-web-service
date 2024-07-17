# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSelectionCommentPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareCommentPageType, null: true
        description 'Get tpc software selection comment page'

        argument :selection_id, Integer, required: true
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(selection_id: nil, page: 1, per: 9)
          selection = TpcSoftwareSelection.find_by(id: selection_id)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?

          items = TpcSoftwareComment.where("metric_name = ?", TpcSoftwareComment::Metric_Name_Selection)
                                    .where("tpc_software_type = ?", TpcSoftwareComment::Type_Selection)
                                    .where("tpc_software_id = ?", selection.id)

          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
    end
  end
end
