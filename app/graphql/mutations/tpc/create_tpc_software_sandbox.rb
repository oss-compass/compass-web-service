# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareSandbox < BaseMutation
      include CompassUtils

      field :status, String, null: false
      field :id, Integer, null: false

      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
      # argument :selection_type, Integer, required: true, description: 'incubation: 0, sandbox: 1, graduation: 2'
      argument :report_category, Integer, required: false, description: 'incubation: 0, sandbox: 2'
      argument :tpc_software_sandbox_report_ids, [Integer], required: true
      argument :repo_url, [String], required: false
      argument :committers, [String], required: true
      argument :adaptation_committers, [String], required: false
      argument :functional_description, String, required: true
      argument :target_software, String, required: true
      argument :is_same_type_check, Integer, required: true
      argument :same_type_software_name, String, required: false

      def resolve(label: nil,
                  level: 'repo',
                  selection_type: 0,
                  report_category: 0,
                  tpc_software_sandbox_report_ids: [],
                  repo_url: [],
                  committers: [],
                  adaptation_committers: [],
                  # incubation_time: nil,
                  # demand_source: nil,
                  # reason: nil,
                  functional_description: nil,
                  target_software: nil,
                  is_same_type_check: 0,
                  same_type_software_name: nil
      )
        label = ShortenedLabel.normalize_label(label)
        current_user = context[:current_user]
        validate_tpc!(current_user)

        subject = Subject.find_by(label: label, level: level)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?
        target_software_report_id = nil
        tpc_software_sandbox_report_ids.each_with_index do |report_id, index|
          tpc_software_sandbox_report = TpcSoftwareSandboxReport.find_by(id: report_id)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_sandbox_report.nil?
          tpc_software_sandbox_report_metric = tpc_software_sandbox_report.tpc_software_sandbox_report_metrics.find_by(
            tpc_software_sandbox_report_type: TpcSoftwareReportMetric::Report_Type_Sandbox,
            version: TpcSoftwareReportMetric::Version_Default)
          if tpc_software_sandbox_report.code_url.end_with?(target_software)
            target_software_report_id = report_id
          end
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_sandbox_report_metric.nil?
          raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_progress') if tpc_software_sandbox_report_metric.status == TpcSoftwareReportMetric::Status_Progress
        end

        sandbox = TpcSoftwareSandbox.create!(
          {
            # selection_type: selection_type,
            report_category: report_category,
            tpc_software_sandbox_report_ids: tpc_software_sandbox_report_ids.any? ? tpc_software_sandbox_report_ids.to_json : nil,
            repo_url: repo_url.join(","),
            committers: committers.any? ? committers.to_json : nil,
            adaptation_committers: adaptation_committers.any? ? adaptation_committers.to_json : nil,
            # incubation_time: incubation_time,
            # demand_source: demand_source,
            # reason: reason,
            functional_description: functional_description,
            target_software: target_software,
            target_software_report_id: target_software_report_id,
            is_same_type_check: is_same_type_check,
            same_type_software_name: same_type_software_name,
            state: TpcSoftwareSandbox.get_report_current_state(target_software_report_id),
            subject_id: subject.id,
            user_id: current_user.id
          }
        )

        { status: true, id: sandbox.id, message: '' }
      rescue => ex
        { status: false, id: '', message: ex.message }
      end
    end
  end
end
