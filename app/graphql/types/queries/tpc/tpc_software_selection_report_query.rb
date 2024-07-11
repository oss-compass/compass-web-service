# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSelectionReportQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareSelectionReportType, null: true
        description 'Get tpc software selection report apply page'
        argument :short_code, String, required: true


        def resolve(short_code: nil)
          current_user = context[:current_user]
          login_required!(current_user)

          report = TpcSoftwareSelectionReport.find_by(short_code: short_code)
          if report
            clarification_permission = TpcSoftwareReportMetricClarificationState.check_permission?(report.tpc_software_sig_id, current_user)
            report_hash = report.attributes
            report_hash['clarification_permission'] = clarification_permission ? 1 : 0
            report = OpenStruct.new(report_hash)
          end
          report
        end
      end
    end
  end
end
