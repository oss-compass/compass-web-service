# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareOutputReportPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareOutputReportPageType, null: true
        description 'Get tpc software output report apply page'
        argument :label, String, required: false, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or project level(repo/community)'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(label: nil, level: nil, page: 1, per: 9)
          current_user = context[:current_user]
          login_required!(current_user)
          validate_by_label!(current_user, label)

          subject = Subject.find_by(label: label, level: level)

          items = []
          if subject.present?
            items = subject.tpc_software_output_reports
          end

          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
    end
  end
end
