# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSelectionReportPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareSelectionReportPageType, null: true
        description 'Get tpc software selection report apply page'
        argument :label, String, required: false, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or project level(repo/community)'
        argument :report_type_list, [Integer], required: true, description: 'incubation: 0, sandbox: 1, graduation: 2'
        argument :status, String, required: false, description: 'progress/success'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(label: nil, level: nil, report_type_list: [], status: nil, page: 1, per: 9)
          current_user = context[:current_user]
          login_required!(current_user)
          validate_by_label!(current_user, label)

          subject = Subject.find_by(label: label, level: level)

          items = []
          if subject.present?
            if status.nil?
              items = subject.tpc_software_selection_reports.where(report_type: report_type_list)
            else
              items = TpcSoftwareSelectionReport.joins(:tpc_software_report_metrics)
                                                .where("tpc_software_selection_reports.subject_id = ?
                                                        And tpc_software_selection_reports.report_type IN (?)
                                                        And tpc_software_report_metrics.status = ?
                                                        And tpc_software_report_metrics.version = ?",
                                                       subject.id, report_type_list, status, TpcSoftwareReportMetric::Version_Default)
            end
          end

          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
    end
  end
end
