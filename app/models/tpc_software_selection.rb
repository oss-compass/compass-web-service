# == Schema Information
#
# Table name: tpc_software_selections
#
#  id                                :bigint           not null, primary key
#  selection_type                    :integer          not null
#  tpc_software_selection_report_ids :string(255)      not null
#  repo_url                          :string(255)
#  committers                        :string(255)      not null
#  reason                            :string(255)      not null
#  subject_id                        :integer          not null
#  user_id                           :integer          not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  incubation_time                   :string(255)      not null
#  adaptation_method                 :string(255)
#  demand_source                     :string(255)
#  functional_description            :string(255)
#  target_software                   :string(255)
#  is_same_type_check                :integer          default(0)
#  same_type_software_name           :string(255)
#  issue_url                         :string(255)
#
class TpcSoftwareSelection < ApplicationRecord

  belongs_to :subject
  belongs_to :user
  has_many :tpc_software_output_reports

  def self.get_review_permission(selection)
    metrics_list = [
      "compliance_license",
      "compliance_license_compatibility",
      "ecology_dependency_acquisition",
      "ecology_adaptation_method",
      "lifecycle_version_normalization",
      "lifecycle_version_lifecycle",
      "security_binary_artifact",
      "security_vulnerability"
    ]

    selection_report_ids = JSON.parse(selection.tpc_software_selection_report_ids)
    report_metrics = TpcSoftwareReportMetric.where(tpc_software_report_id: selection_report_ids)
                                            .where(tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection)
                                            .where(version: TpcSoftwareReportMetric::Version_Default)
    target_report_metric = nil
    report_metrics.each do |report_metric|
      if report_metric.code_url.include?(selection.target_software)
        target_report_metric = report_metric
      end
    end
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if target_report_metric.nil?
    comment_state_list = TpcSoftwareCommentState.where(tpc_software_id: target_report_metric.id)
                                                .where(tpc_software_type: TpcSoftwareCommentState::Type_Report_Metric)
                                                .where(metric_name: metrics_list.map { |str| str.camelize(:lower) })
    comment_state_list.any? { |item| item[:state] == -1 } ? false : true

  end
end
