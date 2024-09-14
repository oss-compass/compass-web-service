# frozen_string_literal: true

module Mutations
  module Tpc
    class UpdateTpcSoftwareSelection < BaseMutation
      include CompassUtils

    field :status, String, null: false

    argument :selection_id, Integer, required: true
    argument :repo_url, [String], required: true
    argument :committers, [String], required: true
    argument :incubation_time, String, required: true
    argument :demand_source, String, required: true
    argument :reason, String, required: true
    argument :functional_description, String, required: true
    argument :is_same_type_check, Integer, required: true
    argument :same_type_software_name, String, required: false

    def resolve(selection_id: nil,
                repo_url: [],
                committers: [],
                incubation_time: nil,
                demand_source: nil,
                reason: nil,
                functional_description: nil,
                is_same_type_check: 0,
                same_type_software_name: nil
                )
      current_user = context[:current_user]
      login_required!(current_user)

      selection = TpcSoftwareSelection.find_by(id: selection_id)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?
      raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || selection.user_id == current_user.id
      before_update_values = selection.attributes
      ActiveRecord::Base.transaction do
        selection.update!(
          {
            repo_url: repo_url.join(","),
            committers: committers.any? ? committers.to_json : nil,
            incubation_time: incubation_time,
            demand_source: demand_source,
            reason: reason,
            functional_description: functional_description,
            is_same_type_check: is_same_type_check,
            same_type_software_name: same_type_software_name,
          }
        )
        after_update_values = selection.reload.attributes
        if before_update_values != after_update_values && selection.issue_url.present?
          TpcSoftwareSelection.update_issue_body(get_issue_body(selection), selection.issue_url)
        end
      end

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end

    def get_issue_body(values)
      committer = (values.committers.present? ? JSON.parse(values.committers) : []).join(",")
      target_software = TpcSoftwareSelectionReport.where(id: JSON.parse(values.tpc_software_selection_report_ids))
                                                  .where("code_url LIKE ?", "%#{values.target_software}")
                                                  .first
      target_software_sig = TpcSoftwareSig.find_by(id: target_software.tpc_software_sig)
      upstream = target_software.code_url
      report_link = "https://oss-compass.org/oh#reportDetailPage?taskId=#{values.id}&projectId=#{target_software.short_code}"

      compare_software_list = TpcSoftwareSelectionReport.where(id: JSON.parse(values.tpc_software_selection_report_ids))
                                                        .where("code_url not LIKE ?", "%#{values.target_software}")
      compare_software_repo_list = []
      compare_software_short_code_list = []
      compare_software_list.each do |compare_software|
        compare_software_repo_list << compare_software.code_url
        compare_software_short_code_list << compare_software.short_code
      end
      if compare_software_repo_list.length > 0
        upstream = "
目标软件上游地址：#{target_software.code_url}
对比软件上游地址：#{compare_software_repo_list.join(" 、 ")}
"
        report_link = "#{report_link}..#{compare_software_short_code_list.join("..")}"
      end

      body = "
  1. 【目标孵化软件】

  > #{values.target_software}

  2. 【需求描述】

  > #{values.reason}

  3. 【功能描述】

  > #{values.functional_description}

  4. 【孵化周期】

  > #{values.incubation_time}

  5. 【垂域 Committers】

  > #{committer}

  6. 【所属领域】

  > #{target_software_sig.name}

  7. 【上游地址】

  > #{upstream}

  8. 【报告链接】

  > #{report_link}
  "
      body
    end

    end
  end
end
