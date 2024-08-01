# == Schema Information
#
# Table name: tpc_software_graduations
#
#  id                                 :bigint           not null, primary key
#  tpc_software_graduation_report_ids :string(255)      not null
#  incubation_start_time              :datetime
#  incubation_time                    :string(255)
#  demand_source                      :string(255)      not null
#  committers                         :string(255)      not null
#  issue_url                          :string(255)
#  subject_id                         :integer          not null
#  user_id                            :integer          not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
class TpcSoftwareGraduation < ApplicationRecord

  belongs_to :subject
  belongs_to :user

  def self.get_review_permission(graduation)
    clarify_metric_list = [
      "compliance_license",
      "compliance_dco",
      "compliance_license_compatibility",
      "compliance_copyright_statement",
      "compliance_copyright_statement_anti_tamper",
      "ecology_readme",
      "ecology_build_doc",
      "ecology_interface_doc",
      "ecology_issue_management",
      "ecology_issue_response_ratio",
      "ecology_issue_response_time",
      "ecology_maintainer_doc",
      "ecology_build",
      "ecology_ci",
      "ecology_test_coverage",
      "ecology_code_review",
      "ecology_code_upstream",
      "lifecycle_release_note",
      "lifecycle_statement",
      "security_binary_artifact",
      "security_vulnerability",
      "security_package_sig"
    ]

    target_metric_list = TpcSoftwareGraduationReportMetric.where(tpc_software_graduation_report_id: JSON.parse(graduation.tpc_software_graduation_report_ids))
                                                          .where(version: TpcSoftwareReportMetric::Version_Default)
    target_metric_list.each do |target_metric|
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if target_metric.nil?
      target_metric_hash = target_metric.attributes

      comment_state_list = TpcSoftwareCommentState.where(tpc_software_id: target_metric.id)
                                                  .where(tpc_software_type: TpcSoftwareCommentState::Type_Graduation_Report_Metric)
                                                  .where(metric_name: clarify_metric_list.map { |str| str.camelize(:lower) })
      committer_state_hash = {}
      sig_leader_state_hash = {}
      comment_state_list.each do |comment_state|
        state_hash = comment_state.member_type == TpcSoftwareCommentState::Member_Type_Committer ? committer_state_hash : sig_leader_state_hash
        (state_hash[comment_state.metric_name] ||= []) << comment_state.state
      end
      clarify_metric_list.each do |clarify_metric|
        score = target_metric_hash[clarify_metric]
        committer_state = committer_state_hash.dig(clarify_metric.camelize(:lower))&.all? { |item| item == TpcSoftwareCommentState::State_Accept } || false
        sig_leader_state = sig_leader_state_hash.dig(clarify_metric.camelize(:lower))&.all? { |item| item == TpcSoftwareCommentState::State_Accept } || false

        if score.present? &&  score < 10 && (!committer_state || !sig_leader_state)
          return false
        end
      end
    end
    true
  end
end
