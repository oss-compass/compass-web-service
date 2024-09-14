# frozen_string_literal: true

module Mutations
  module Tpc
    class UpdateTpcSoftwareGraduation < BaseMutation
      include CompassUtils

    field :status, String, null: false

    argument :graduation_id, Integer, required: true
    argument :incubation_start_time, GraphQL::Types::ISO8601DateTime, required: false
    argument :incubation_time, String, required: false
    argument :demand_source, String, required: true
    argument :committers, [String], required: true
    argument :functional_description, String, required: true

    def resolve(graduation_id: nil,
                incubation_start_time: nil,
                incubation_time: nil,
                demand_source: nil,
                committers: [],
                functional_description: nil
                )
      current_user = context[:current_user]
      login_required!(current_user)

      graduation = TpcSoftwareGraduation.find_by(id: graduation_id)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if graduation.nil?
      raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || graduation.user_id == current_user.id
      before_update_values = graduation.attributes
      ActiveRecord::Base.transaction do
        graduation.update!(
          {
            incubation_start_time: incubation_start_time,
            incubation_time: incubation_time,
            demand_source: demand_source,
            committers: committers.any? ? committers.to_json : nil,
            functional_description: functional_description
          }
        )
        after_update_values = graduation.reload.attributes
        if before_update_values != after_update_values && graduation.issue_url.present?
          TpcSoftwareGraduation.update_issue_body(get_issue_body(graduation), graduation.issue_url)
        end
      end

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end

      def get_issue_body(values)
        target_software = TpcSoftwareGraduationReport.where(id: JSON.parse(values.tpc_software_graduation_report_ids))
                                                     .first

        target_name = URI.parse(target_software.code_url).path.sub(/^\//, '')
        committer = (values.committers.present? ? JSON.parse(values.committers) : []).join(",")

        target_software_sig = TpcSoftwareSig.find_by(id: target_software.tpc_software_sig)
        upstream = target_software.code_url
        report_link = "https://oss-compass.org/oh#graduationReportPage?taskId=#{values.id}&projectId=#{target_software.short_code}"

        body = "
  1. 【毕业软件】

  > #{target_name}

  2. 【需求来源】

  > #{values.demand_source}

  3. 【垂域 Committers】

  > #{committer}

  4. 【所属领域】

  > #{target_software_sig.name}

  5. 【仓库地址】

  > #{upstream}

  6. 【报告链接】

  > #{report_link}
  "
        body
      end

  end
  end
end
