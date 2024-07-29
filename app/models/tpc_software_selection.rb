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
    clarify_metric_list = [
      "compliance_license",
      "compliance_license_compatibility",
      "ecology_dependency_acquisition",
      "ecology_code_maintenance",
      "ecology_community_support",
      "ecology_adaptation_method",
      "ecology_adoption_analysis",
      "ecology_patent_risk",
      "lifecycle_version_normalization",
      "lifecycle_version_lifecycle",
      "security_binary_artifact",
      "security_vulnerability"
    ]

    target_metric = TpcSoftwareReportMetric.where(tpc_software_report_id: JSON.parse(selection.tpc_software_selection_report_ids))
                                                  .where(tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection)
                                                  .where(version: TpcSoftwareReportMetric::Version_Default)
                                                  .where("code_url LIKE ?", "%#{selection.target_software}%")
                                                  .take
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if target_metric.nil?
    target_metric_hash = target_metric.attributes
    target_metric_hash['ecology_adaptation_method'] = TpcSoftwareReportMetric.get_ecology_adaptation_method(target_metric.tpc_software_report_id)

    comment_state_list = TpcSoftwareCommentState.where(tpc_software_id: target_metric.id)
                                                .where(tpc_software_type: TpcSoftwareCommentState::Type_Report_Metric)
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
    true
  end
end
