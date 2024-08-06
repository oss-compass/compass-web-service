# == Schema Information
#
# Table name: tpc_software_graduations
#
#  id                                 :bigint           not null, primary key
#  tpc_software_graduation_report_ids :string(255)      not null
#  incubation_start_time              :datetime
#  incubation_time                    :string(255)
#  demand_source                      :string(2000)     not null
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

  def self.get_review_permission(graduation, member_type)
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
      legal_state_hash = {}
      compliance_state_hash = {}
      comment_state_list.each do |comment_state|
        state_hash = {}
        case comment_state.member_type
        when TpcSoftwareCommentState::Member_Type_Committer
          state_hash = committer_state_hash
        when TpcSoftwareCommentState::Member_Type_Sig_Lead
          state_hash = sig_leader_state_hash
        when TpcSoftwareCommentState::Member_Type_Legal
          state_hash = legal_state_hash
        when TpcSoftwareCommentState::Member_Type_Compliance
          state_hash = compliance_state_hash
        end
        (state_hash[comment_state.metric_name] ||= []) << comment_state.state
      end
      clarify_metric_list.each do |clarify_metric|
        score = target_metric_hash[clarify_metric]
        lower_clarify_metric = clarify_metric.camelize(:lower)
        committer_state = committer_state_hash.dig(lower_clarify_metric)&.all? { |item| item == TpcSoftwareCommentState::State_Accept } || false
        sig_leader_state = sig_leader_state_hash.dig(lower_clarify_metric)&.all? { |item| item == TpcSoftwareCommentState::State_Accept } || false
        legal_state = legal_state_hash.dig(lower_clarify_metric)&.all? { |item| item == TpcSoftwareCommentState::State_Accept } || false
        compliance_state = compliance_state_hash.dig(lower_clarify_metric)&.all? { |item| item == TpcSoftwareCommentState::State_Accept } || false

        if score.present? &&  score < 10
          case member_type
          when TpcSoftwareCommentState::Member_Type_Committer
            if !TpcSoftwareCommentState.check_compliance_metric(lower_clarify_metric) && !committer_state
              return false
            end
          when TpcSoftwareCommentState::Member_Type_Sig_Lead
            if !TpcSoftwareCommentState.check_compliance_metric(lower_clarify_metric) && !sig_leader_state
              return false
            end
          when TpcSoftwareCommentState::Member_Type_Legal
            if TpcSoftwareCommentState.check_compliance_metric(lower_clarify_metric) && !legal_state
              return false
            end
          when TpcSoftwareCommentState::Member_Type_Compliance
            if !compliance_state
              return false
            end
          end
        end
      end
    end
    true
  end

  def self.save_issue_url(id, issue_html_url)
    graduation = TpcSoftwareGraduation.find_by(id: id)
    if graduation.present?
      graduation.update!(issue_url: issue_html_url)
    end
  end


  def self.update_issue_title(id, issue_title, issue_html_url)
    review_state = TpcSoftwareCommentState.get_review_state(id, TpcSoftwareCommentState::Type_Graduation)
    TpcSoftwareCommentState::Review_States.each do |state|
      if issue_title.include?(state)
        to_issue_title = issue_title.gsub(state, review_state)
        issue_url_list = issue_html_url.split("/issues/")
        subject_customization = SubjectCustomization.find_by(name: "OpenHarmony")
        if issue_url_list.length && subject_customization.present?
          repo_url = issue_url_list[0]
          number = issue_url_list[1]
          if repo_url.include?("gitee.com")
            IssueServer.new(
              {
                repo_url: repo_url,
                gitee_token: subject_customization.gitee_token,
                github_token: nil
              }
            ).update_gitee_issue_title(number, to_issue_title)
          end
        end
        break
      end
    end
  end


  def self.send_apply_email(mail_list, user_name, user_html_url, issue_title, issue_html_url)
    if mail_list.length > 0
      title = "TPC毕业项目申请"
      body = "用户正在申请OpenHarmony TPC毕业项目，具体如下："
      state_list = TpcSoftwareCommentState::Review_States
      issue_title = issue_title.gsub(Regexp.union(state_list), '')
      mail_list.each do |mail|
        UserMailer.with(
          type: 0,
          title: title,
          body: body,
          user_name: user_name,
          user_html_url: user_html_url,
          issue_title: issue_title,
          issue_html_url: issue_html_url,
          email: mail
        ).email_tpc_software_application.deliver_later
      end
    end

  end


  def self.send_review_email(mail_list, user_name, user_html_url, issue_title, issue_html_url, comment)
    if mail_list.length > 0
      title = "TPC毕业项目评审"
      body = "用户正在申请OpenHarmony TPC毕业项目，#{comment}，具体如下："
      state_list = TpcSoftwareCommentState::Review_States
      issue_title = issue_title.gsub(Regexp.union(state_list), '')
      mail_list.each do |mail|
        UserMailer.with(
          type: 1,
          title: title,
          body: body,
          user_name: user_name,
          user_html_url: user_html_url,
          issue_title: issue_title,
          issue_html_url: issue_html_url,
          email: mail
        ).email_tpc_software_application.deliver_later
      end
    end
  end


end
