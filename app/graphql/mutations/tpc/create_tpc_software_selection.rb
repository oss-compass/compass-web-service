# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareSelection < BaseMutation
      include CompassUtils

      OH_TPC_REPO = ENV.fetch('OH_TPC_REPO')
      OH_TPC_REPO_TOKEN = ENV.fetch('OH_TPC_REPO_TOKEN')

    field :status, String, null: false
    field :issue_url, String, null: true

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
    argument :selection_type, Integer, required: true, description: 'selection: 0, create_repo: 1, incubation: 2'
    argument :tpc_software_selection_report_ids, [Integer], required: true
    argument :repo_url, String, required: false
    argument :committers, [String], required: true
    argument :incubation_time, GraphQL::Types::ISO8601DateTime, required: true
    argument :reason, String, required: true
    argument :adaptation_method, Integer, required: true, description: 'adaptation: 0, rewrite: 1', default_value: '0'

    def resolve(label: nil,
                level: 'repo',
                selection_type: 0,
                tpc_software_selection_report_ids: [],
                repo_url: nil,
                committers: [],
                incubation_time: nil,
                reason: nil,
                adaptation_method: 0
                )
      label = ShortenedLabel.normalize_label(label)
      current_user = context[:current_user]
      login_required!(current_user)

      software_name = nil
      software_release = nil
      upstream_repo_url_list = []
      short_code_list = []

      subject = Subject.find_by(label: label, level: level)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?
      tpc_software_selection_report_ids.each_with_index do |report_id, index|
        tpc_software_selection_report = TpcSoftwareSelectionReport.find_by(id: report_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_selection_report.nil?
        tpc_software_report_metric = tpc_software_selection_report.tpc_software_report_metrics.find_by(
          tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
          version: TpcSoftwareReportMetric::Version_Default)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_report_metric.nil?
        raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_progress') if tpc_software_report_metric.status == TpcSoftwareReportMetric::Status_Progress
        if index == 0
          software_name = tpc_software_selection_report.name
          software_release = tpc_software_selection_report.release
        end
        upstream_repo_url_list.push(tpc_software_selection_report.code_url)
        short_code_list.push(tpc_software_selection_report.short_code)

      end

      issue_url = nil
      ActiveRecord::Base.transaction do
        if selection_type == 0
          selection_type_name = "沙箱选型"
        elsif selection_type == 1
          selection_type_name = "沙箱已建仓"
        elsif selection_type == 2
          selection_type_name = "孵化"
        end
        issue_title = "【TPC】【#{selection_type_name}申请】 #{software_name} #{software_release}申请进入OpenHarmony TPC #{selection_type_name}项目"
        issue_body = "需求背景：#{reason}
                      上游地址：#{upstream_repo_url_list.join(", ")}
                      报告链接：https://oss-compass.org/oh#reportDetailPage?projectId=#{short_code_list.join("..")}"
        result = IssueServer.new({repo_url: OH_TPC_REPO})
                            .create_gitee_issue(OH_TPC_REPO_TOKEN, issue_title, issue_body)
        Rails.logger.info "CreateTpcSoftwareSelection: #{result}"
        Rails.logger.info "OH_TPC_REPO:#{OH_TPC_REPO}"
        Rails.logger.info "OH_TPC_REPO_TOKEN:#{OH_TPC_REPO_TOKEN}"
        raise GraphQL::ExecutionError.new result[:message] unless result[:status]

        issue_url = result[:issue_url]

        TpcSoftwareSelection.create!(
          {
            selection_type: selection_type,
            tpc_software_selection_report_ids: tpc_software_selection_report_ids.any? ? tpc_software_selection_report_ids.to_json : nil,
            repo_url: repo_url,
            committers: committers.any? ? committers.to_json : nil,
            incubation_time: incubation_time,
            reason: reason,
            adaptation_method: adaptation_method,
            issue_url: issue_url,
            subject_id: subject.id,
            user_id: current_user.id
          }
        )

      end

      { status: true, issue_url: issue_url, message: '' }
    rescue => ex
      { status: false, issue_url: nil, message: ex.message }
    end
  end
  end
end
