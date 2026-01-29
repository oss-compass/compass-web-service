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
#  demand_source                     :string(2000)
#  functional_description            :string(2000)
#  target_software                   :string(255)
#  is_same_type_check                :integer          default(0)
#  same_type_software_name           :string(255)
#  issue_url                         :string(255)
#  state                             :integer
#  target_software_report_id         :integer
#  report_category                   :integer
#  remark                            :string(255)
#
class TpcSoftwareSelection < ApplicationRecord

  belongs_to :subject
  belongs_to :user
  belongs_to :tpc_software_selection_report, foreign_key: 'target_software_report_id'
  belongs_to :tpc_software_report, foreign_key: 'target_software_report_id', class_name: 'TpcSoftwareSelectionReport'

  State_Awaiting_Clarification = 0
  State_Awaiting_Confirmation = 1
  State_Awaiting_Review = 2

  State_Awaiting_QA = 4
  State_Completed = 3
  State_Repo_Created = 5
  State_Repo_Created_Error = 6
  State_Rejected = -1

  Clarify_Metric_List = [
    "compliance_license",
    "compliance_license_compatibility",
    "ecology_patent_risk",
    "ecology_dependency_acquisition",
    "ecology_code_maintenance",
    "ecology_community_support",
    "ecology_adaptation_method",
    "ecology_adoption_analysis",
    "lifecycle_version_normalization",
    "lifecycle_version_lifecycle",
    "security_binary_artifact",
    "security_vulnerability",
    "upstream_collaboration_strategy"
  ]

  def self.get_review_permission(selection, member_type)
    clarify_metric_list = TpcSoftwareSelection::Clarify_Metric_List

    target_metric = TpcSoftwareReportMetric.where(tpc_software_report_id: JSON.parse(selection.tpc_software_selection_report_ids))
                                                  .where(tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection)
                                                  .where(version: TpcSoftwareReportMetric::Version_Default)
                                                  .where("code_url LIKE ?", "%#{selection.target_software}%")
                                                  .take
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if target_metric.nil?
    target_metric_hash = target_metric.attributes
    target_metric_hash['ecology_adaptation_method'] = target_metric.get_ecology_adaptation_method

    comment_state_list = TpcSoftwareCommentState.where(tpc_software_id: target_metric.id)
                                                .where(tpc_software_type: TpcSoftwareCommentState::Type_Report_Metric)
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


      if score.present? && (0 <= score) && (score < 10)
        if clarify_metric == "upstream_collaboration_strategy"
          return true
        end
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
          if clarify_metric != "upstream_collaboration_strategy"
            if !compliance_state
              return false
            end
          end
        end
      end
    end
    true
  end

  def self.get_risk_metric_list(report_id)
    target_metric = TpcSoftwareReportMetric.where(tpc_software_report_id: report_id)
                                           .where(tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection)
                                           .where(version: TpcSoftwareReportMetric::Version_Default)
                                           .take
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if target_metric.nil?
    target_metric_hash = target_metric.attributes
    target_metric_hash['ecology_adaptation_method'] = target_metric.get_ecology_adaptation_method

    risk_metric_list = []
    TpcSoftwareSelection::Clarify_Metric_List.each do |clarify_metric|
      score = target_metric_hash[clarify_metric]
      if score.present? && (0 <= score) && (score < 10)
        risk_metric_list << clarify_metric.camelize(:lower)
      end
    end
    risk_metric_list
  end

  def self.get_clarified_metric_list(report_id)
    target_metric = TpcSoftwareReportMetric.where(tpc_software_report_id: report_id)
                                           .where(tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection)
                                           .where(version: TpcSoftwareReportMetric::Version_Default)
                                           .take
    comment_list = TpcSoftwareComment.where(tpc_software_id: target_metric.id)
                                     .where(tpc_software_type: TpcSoftwareComment::Type_Report_Metric)
                                     .where(metric_name: get_risk_metric_list(report_id))
    comment_metric_name_list = comment_list.map do |comment_item|
      comment_item.metric_name
    end
    comment_metric_name_list.uniq
  end

  def self.get_confirmed_metric_list(report_id)
    risk_metric_list = get_risk_metric_list(report_id)
    target_metric = TpcSoftwareReportMetric.where(tpc_software_report_id: report_id)
                                           .where(tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection)
                                           .where(version: TpcSoftwareReportMetric::Version_Default)
                                           .take
    comment_state_list = TpcSoftwareCommentState.where(tpc_software_id: target_metric.id)
                                                .where(tpc_software_type: TpcSoftwareCommentState::Type_Report_Metric)
                                                .where(metric_name: risk_metric_list)
    member_type_hash = comment_state_list.each_with_object({}) do |comment_state_item, hash|
      (hash[comment_state_item.metric_name] ||= []) << comment_state_item.member_type
    end
    confirmed_metrics = []
    risk_metric_list.each do |risk_metric|
      if member_type_hash.key?(risk_metric)
        member_type_list = member_type_hash[risk_metric]


        if risk_metric == "upstreamCollaborationStrategy" && member_type_list.include?(TpcSoftwareCommentState::Member_Type_Community_Collaboration_WG)
          confirmed_metrics << risk_metric
          next
        end

        if TpcSoftwareCommentState.check_compliance_metric(risk_metric)
          if [TpcSoftwareCommentState::Member_Type_Compliance,
              TpcSoftwareCommentState::Member_Type_Legal].all? { |element| member_type_list.include?(element) }
            confirmed_metrics << risk_metric
          end
        else
          if [TpcSoftwareCommentState::Member_Type_Compliance,
              # TpcSoftwareCommentState::Member_Type_Committer,
              TpcSoftwareCommentState::Member_Type_Sig_Lead].all? { |element| member_type_list.include?(element) }
            confirmed_metrics << risk_metric
          end
        end
      end
    end
    confirmed_metrics
  end

  def self.get_comment_state_list(selection_id)
    TpcSoftwareCommentState.where(tpc_software_id: selection_id)
                           .where(metric_name: TpcSoftwareCommentState::Metric_Name_Selection)
  end


  def self.get_report_current_state(report_id)
    risk_metric_count = get_risk_metric_list(report_id).length
    clarified_metric_count = get_clarified_metric_list(report_id).length
    if risk_metric_count != clarified_metric_count
      return State_Awaiting_Clarification
    end

    confirmed_metric_count = get_confirmed_metric_list(report_id).length
    if risk_metric_count != confirmed_metric_count
      return State_Awaiting_Confirmation
    end
    State_Awaiting_Review
  end

  def self.get_upstream_collaboration_strategy_score(report_id)
    # code here
    report_metric = TpcSoftwareReportMetric.where(tpc_software_report_id: report_id)
    return report_metric.take.upstream_collaboration_strategy if report_metric.present?
  end

  def self.get_current_state(tpc_software)
    report_id = tpc_software.target_software_report_id
    risk_metric_count = get_risk_metric_list(report_id).length
    clarified_metric_count = get_clarified_metric_list(report_id).length
    if risk_metric_count != clarified_metric_count
      Rails.logger.info("risk_metric_count != clarified_metric_count")
      return State_Awaiting_Clarification
    end

    confirmed_metric_count = get_confirmed_metric_list(report_id).length
    if risk_metric_count != confirmed_metric_count
      Rails.logger.info("risk_metric_count != confirmed_metric_count")
      return State_Awaiting_Confirmation
    end

    comment_state_list = get_comment_state_list(tpc_software.id)
    upstream_collaboration_strategy_score = get_upstream_collaboration_strategy_score(report_id)

    required_member_types = if upstream_collaboration_strategy_score == 10  || upstream_collaboration_strategy_score < 0 || upstream_collaboration_strategy_score.nil?
                              TpcSoftwareCommentState::Selection_Member_Types - [TpcSoftwareCommentState::Member_Type_Community_Collaboration_WG]
                            else
                              TpcSoftwareCommentState::Selection_Member_Types
                            end

    if comment_state_list.any? { |item| item.state == TpcSoftwareCommentState::State_Reject }
      return State_Rejected
    elsif (required_member_types + [TpcSoftwareCommentState::Member_Type_QA]).all? { |member_type| comment_state_list.any? { |item| item[:member_type] == member_type && item[:state] == TpcSoftwareCommentState::State_Accept } }
      return State_Completed
    elsif required_member_types.all? { |member_type| comment_state_list.any? { |item| item[:member_type] == member_type && item[:state] == TpcSoftwareCommentState::State_Accept } }
      return State_Awaiting_QA
    else
      return State_Awaiting_Review
    end
  end

  def self.update_state(id)
    selection = TpcSoftwareSelection.find_by(id: id)
    state = get_current_state(selection)
    selection.update!(state: state)
    # selection_report = selection.tpc_software_report
    # repo_url = selection.repo_url

    # need_autocreate =
    #   [2, 3].include?(selection_report.tpc_software_sig_id) ||
    #     repo_url.to_s.include?("https://gitcode.com/openharmony-ApplicationTPC")
    #
    need_autocreate = check_auto_create_permission(selection)
    return unless need_autocreate

    if state == State_Completed
      create_msg = perform_gitcode_automation(selection)
      if create_msg == true
        selection.update!(state: State_Repo_Created)
      else
        selection.update!(state: State_Repo_Created_Error, remark: create_msg)
      end
    end

  end

  def self.check_auto_create_permission(selection)
    repo_url = selection.repo_url
    return false if repo_url.blank?

    keywords = TpcAutoCreateOrg.enabled.pluck(:org_url)
    repo_url_down = repo_url.downcase
    matched = keywords.any? { |keyword| keyword.present? && repo_url_down.include?(keyword.downcase) }
    if matched
      Rails.logger.info "[AutoRepo] Selection ##{selection.id} 匹配到自动建仓组织 (URL: #{repo_url})"
    end
    matched
  end
  def self.perform_gitcode_automation(selection)
    Rails.logger.info "[AutoRepo] 开始处理 selection ID: #{selection.id}"
    selection_report = selection.tpc_software_report
    # sig = selection_report.tpc_software_sig_id
    # repo_owner_map = {
    #   2 => ENV["ORG_REPO_OWNER_SIG2"],
    #   3 => ENV["ORG_REPO_OWNER_SIG3"],
    #   20 => ENV["ORG_REPO_OWNER_SIG20"],
    # }
    #
    # sig_id_for_repo =
    #   if selection.repo_url.include?("https://gitcode.com/openharmony-ApplicationTPC")
    #     # 通用三方库
    #     20
    #   else
    #     sig
    #   end

    # 去掉首尾空格和末尾斜杠
    full_repo_url = selection.repo_url.to_s.strip.chomp('/')
    # 找到最后一个 '/' 的位置，截取它之前的所有内容
    last_slash_index = full_repo_url.rindex('/')
    if last_slash_index
      target_org_url = full_repo_url[0...last_slash_index]
    else
      target_org_url = full_repo_url
    end

    matched_org = TpcAutoCreateOrg.enabled
                                  .where("LOWER(org_url) = ?", target_org_url.downcase)
                                  .first


    repo_owner = matched_org.name

    # repo_owner = repo_owner_map[sig_id_for_repo] || ""
    # 是否是组织仓库
    is_org_repo = true
    repo_name = selection.repo_url.split('/').last

    source_url = selection_report.code_url

    gitcode_server = GitcodeServer.new

    method = selection_report.adaptation_method
    # 如果 method 时 Java库重写 创建空白库
    import_url = if method == "Java库重写"
                   nil
                 else
                   source_url.presence
                 end

    # 创建仓库
    repo_info = {
      owner: repo_owner,
      is_org: is_org_repo,
      name: repo_name,
      description: selection.functional_description,
      #导入链接
      import_url: import_url,
      auto_init: import_url.blank?,
      default_branch: 'main'
    }


    Rails.logger.info "建仓参数 #{repo_info.to_json}"
    created_repo = gitcode_server.create_repo(repo_info)

    if created_repo != true
      Rails.logger.error "[AutoRepo] 建仓失败，终止流程。"
      return created_repo
    end


    if source_url.present?
      Rails.logger.info "[AutoRepo] 正在等待仓库初始化/导入..."
      # sleep(5)
    end

    begin
      gitcode_server.update_repo_model(repo_owner, repo_name)
    rescue StandardError => e
      Rails.logger.error "[AutoRepo] 设置权限模式失败，终止后续流程: #{e.message}"
      return created_repo
    end

    # 添加协作者 (Committers)
    # committers = TpcSoftwareMember.where(tpc_software_sig_id: sig_id_for_repo)
    #                               .where(member_type: TpcSoftwareMember::Member_Type_Sig_Committer)
    #                               .where.not(gitcode_account: nil)

    committers = matched_org.tpc_auto_create_committers

    if committers.present?
      Rails.logger.info "[AutoRepo] 找到 #{committers.count} 个协作者，开始添加..."

      committers.each do |member|
        username = member.gitcode_account
        next if username.blank?
        # permission = member.role_level.to_i > 2 ? 'admin' : 'push'
        permission = member.role

        begin
          gitcode_server.add_collaborator(repo_owner, repo_name, username, permission)
          sleep(0.2)
        rescue StandardError => e
          error_msg = e.message.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
          Rails.logger.error "[AutoRepo] 添加协作者 [#{username}] (Role: #{permission}) 失败: #{error_msg}"
        end
      end
    else
      Rails.logger.info "[AutoRepo] 未找到符合条件的协作者，跳过此步骤。"
    end

    gitcode_server.create_label(repo_owner, repo_name, '孵化')


    Rails.logger.info "[AutoRepo] selection ##{selection.id} 自动化流程全部完成。"
  end
  def self.save_issue_url(id, issue_html_url)
    selection = TpcSoftwareSelection.find_by(id: id)
    if selection.present?
      selection.update!(issue_url: issue_html_url)
    end
  end


  def self.update_issue_title(id, issue_title, issue_html_url)
    review_state = TpcSoftwareCommentState.get_review_state(id, TpcSoftwareCommentState::Type_Selection)
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


  def self.update_issue_body(issue_body, issue_html_url)
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
        ).update_gitee_issue_body(number, issue_body)
      end
    end
  end


  def self.send_apply_email(mail_list, user_name, user_html_url, issue_title, issue_html_url)
    if mail_list.length > 0
      title = "TPC孵化项目申请"
      body = "用户正在申请项目进入 OpenHarmony TPC，具体如下："
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
      title = "TPC孵化项目评审"
      body = "用户正在申请项目进入 OpenHarmony TPC，#{comment}，具体如下："
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
