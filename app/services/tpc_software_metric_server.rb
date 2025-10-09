# frozen_string_literal: true

class TpcSoftwareMetricServer

  include Common
  include CompassUtils

  DEFAULT_HOST = ENV.fetch('DEFAULT_HOST')

  TPC_SERVICE_API_ENDPOINT = ENV.fetch('TPC_SERVICE_API_ENDPOINT')
  TPC_SERVICE_API_USERNAME = ENV.fetch('TPC_SERVICE_API_USERNAME')
  TPC_SERVICE_API_PASSWORD = ENV.fetch('TPC_SERVICE_API_PASSWORD')
  TPC_SERVICE_CALLBACK_URL = "#{DEFAULT_HOST}/api/tpc_software_callback"

  Report_Type_Selection = 0
  Report_Type_Graduation = 1
  Report_Type_Lectotype = 2
  Report_Type_License = -1
  Report_Type_Metrics_Model = -2

  def initialize(opts = {})
    @project_url = opts[:project_url]
  end

  def analyze_metric_by_compass(report_id, report_metric_id, report_type)
    result = AnalyzeServer.new(
      {
        repo_url: @project_url,
        callback: {
          hook_url: TPC_SERVICE_CALLBACK_URL,
          params: {
            callback_type: "tpc_software_callback",
            task_metadata: {
              report_id: report_id,
              report_metric_id: report_metric_id,
              report_type: report_type
            }
          }
        }
      }
    ).execute_tpc
    Rails.logger.info("analyze metric by compass info: #{result}")
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
  end

  def analyze_metric_by_tpc_service(report_id, report_metric_id, oh_commit_sha, report_type)
    token = tpc_service_token
    case report_type
    when Report_Type_Selection
      commands = %w[osv-scanner scancode binary-checker sonar-scanner dependency-checker]
    when Report_Type_Graduation
      commands = %w[scancode sonar-scanner binary-checker osv-scanner release-checker readme-checker
                    maintainers-checker build-doc-checker api-doc-checker readme-opensource-checker
                    changed-files-since-commit-detector oat-scanner]
    end
    payload = {
      commands: commands,
      project_url: "#{@project_url}.git",
      callback_url: TPC_SERVICE_CALLBACK_URL,
      commit_hash: oh_commit_sha,
      task_metadata: {
        report_id: report_id,
        report_metric_id: report_metric_id,
        report_type: report_type
      }
    }
    result = base_post_request("opencheck", payload, token: token)
    Rails.logger.info("analyze metric by tpc service info: #{result}")
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
  end

  def self.create_issue_workflow(payload)
    issue_title = payload.dig('issue', 'title')
    issue_body = payload.dig('issue', 'body')
    issue_html_url = payload.dig('issue', 'html_url')
    user_html_url = payload.dig('issue', 'user', 'html_url')
    user_name = payload.dig('issue', 'user', 'name')

    Rails.logger.info("create_issue_workflow info: issue_html_url: #{issue_html_url}")


    if issue_title.include?("【孵化选型申请】") || issue_title.include?("【孵化申请】")
      # save issue url
      issue_body_taskId_matched = issue_body.match(/taskId=(.*?)&projectId=/)
      if issue_body_taskId_matched
        task_id = issue_body_taskId_matched[1].to_i
        TpcSoftwareSelection.save_issue_url(task_id, issue_html_url)
      end

      # send email
      issue_body_matched = issue_body.match(/projectId=([^&]+)/)
      if issue_body_matched
        short_code = issue_body_matched[1]
        short_code_list = short_code.split("..").map(&:strip)
        mail_list = TpcSoftwareMember.get_email_notify_list(short_code_list.first, Report_Type_Selection)
        TpcSoftwareSelection.send_apply_email(mail_list, user_name, user_html_url, issue_title, issue_html_url)
      end
    end

    if issue_title.include?("【毕业申请】")
      # save issue url
      issue_body_taskId_matched = issue_body.match(/taskId=(.*?)&projectId=/)
      if issue_body_taskId_matched
        task_id = issue_body_taskId_matched[1].to_i
        TpcSoftwareGraduation.save_issue_url(task_id, issue_html_url)
      end

      # send email
      issue_body_matched = issue_body.match(/projectId=([^&]+)/)
      if issue_body_matched
        short_code = issue_body_matched[1]
        short_code_list = short_code.split("..").map(&:strip)
        mail_list = TpcSoftwareMember.get_email_notify_list(short_code_list.first, Report_Type_Graduation)
        TpcSoftwareGraduation.send_apply_email(mail_list, user_name, user_html_url, issue_title, issue_html_url)
      end
    end
  end

  def self.create_issue_comment_workflow(payload)
    issue_title = payload.dig('issue', 'title')
    issue_body = payload.dig('issue', 'body')
    issue_html_url = payload.dig('issue', 'html_url')
    user_html_url = payload.dig('issue', 'user', 'html_url')
    user_name = payload.dig('issue', 'user', 'name')
    comment = payload.dig('note')

    Rails.logger.info("create_issue_comment_workflow info: issue_html_url: #{issue_html_url}")

    if (issue_title.include?("【孵化选型申请】") || issue_title.include?("【孵化申请】")) &&
      TpcSoftwareCommentState::Member_Type_Names.any? { |word| comment.start_with?(word) }
      issue_body_taskId_matched = issue_body.match(/taskId=(.*?)&projectId=/)
      if issue_body_taskId_matched
        # save issue url
        task_id = issue_body_taskId_matched[1].to_i
        TpcSoftwareSelection.save_issue_url(task_id, issue_html_url)
        # update issue title
        TpcSoftwareSelection.update_issue_title(task_id, issue_title, issue_html_url)
      end

      # send email
      issue_body_matched = issue_body.match(/projectId=([^&]+)/)
      if issue_body_matched
        short_code = issue_body_matched[1]
        short_code_list = short_code.split("..").map(&:strip)
        mail_list = TpcSoftwareMember.get_email_notify_list(short_code_list.first, Report_Type_Selection)
        TpcSoftwareSelection.send_review_email(mail_list, user_name, user_html_url, issue_title, issue_html_url, comment)
      end
    end

    if issue_title.include?("【毕业申请】") && TpcSoftwareCommentState::Member_Type_Names.any? { |word| comment.start_with?(word) }
      issue_body_taskId_matched = issue_body.match(/taskId=(.*?)&projectId=/)
      if issue_body_taskId_matched
        # save issue url
        task_id = issue_body_taskId_matched[1].to_i
        TpcSoftwareGraduation.save_issue_url(task_id, issue_html_url)
        # update issue title
        TpcSoftwareGraduation.update_issue_title(task_id, issue_title, issue_html_url)
      end

      # send email
      issue_body_matched = issue_body.match(/projectId=([^&]+)/)
      if issue_body_matched
        short_code = issue_body_matched[1]
        short_code_list = short_code.split("..").map(&:strip)
        mail_list = TpcSoftwareMember.get_email_notify_list(short_code_list.first, Report_Type_Graduation)
        TpcSoftwareGraduation.send_review_email(mail_list, user_name, user_html_url, issue_title, issue_html_url, comment)
      end
    end

  end


  def tpc_software_selection_callback(command_list, scan_results, report_id, report_metric_id)
    code_count = nil
    license = nil
    # commands = ["osv-scanner", "scancode", "binary-checker", "sonar-scanner", "dependency-checker", "compass"]
    tpc_software_selection_report = TpcSoftwareSelectionReport.find_by(id: report_id)
    oh_commit_sha = tpc_software_selection_report.oh_commit_sha
    upstream_collaboration_strategy = tpc_software_selection_report.upstream_collaboration_strategy

    metric_hash = Hash.new
    command_list.each do |command|
      case command
      when "osv-scanner"
        metric_hash.merge!(TpcSoftwareReportMetric.get_security_vulnerability(scan_results.dig(command) || {}))
      when "scancode"
        metric_hash.merge!(TpcSoftwareReportMetric.get_compliance_license(scan_results.dig(command) || {}))
        metric_hash.merge!(TpcSoftwareReportMetric.get_compliance_license_compatibility(scan_results.dig(command) || {}, nil))
        license = TpcSoftwareReportMetric.get_license(scan_results.dig(command) || {})
      when "binary-checker"
        metric_hash.merge!(TpcSoftwareReportMetric.get_security_binary_artifact(scan_results.dig(command) || {},nil))
      when "sonar-scanner"
        metric_hash.merge!(TpcSoftwareReportMetric.get_ecology_software_quality(scan_results.dig(command) || {}))
        code_count = TpcSoftwareReportMetric.get_code_count(scan_results.dig(command) || {})
      when "dependency-checker"
        metric_hash.merge!(TpcSoftwareReportMetric.get_ecology_dependency_acquisition(scan_results.dig(command) || {}))
      when "compass"
                
        begin
          metric_hash.merge!(TpcSoftwareReportMetric.get_compliance_dco(@project_url, oh_commit_sha))
        rescue => e
          Rails.logger.error("Error in get_compliance_dco: #{e.message}")
        end

        metric_hash.merge!(TpcSoftwareReportMetric.get_ecology_code_maintenance(@project_url))
        metric_hash.merge!(TpcSoftwareReportMetric.get_ecology_community_support(@project_url))
        metric_hash.merge!(TpcSoftwareReportMetric.get_upstream_collaboration_strategy(upstream_collaboration_strategy))

        begin
          metric_hash.merge!(TpcSoftwareReportMetric.get_security_history_vulnerability(@project_url))
        rescue => e
          Rails.logger.error("Error in get_security_history_vulnerability: #{e.message}")
        end

        metric_hash.merge!(TpcSoftwareReportMetric.get_lifecycle_version_lifecycle(@project_url))
      when "oat-scanner"
        # no process
      else
        raise GraphQL::ExecutionError.new I18n.t('tpc.callback_command_not_exist', command: command)
      end
    end
    tpc_software_report_metric = TpcSoftwareReportMetric.find_by(id: report_metric_id)
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_report_metric.nil?

    report_metric_data = metric_hash.select { |key, _| !key.end_with?("_raw") }
    report_metric_raw_data = metric_hash.select { |key, _| key.end_with?("_raw") }
    if command_list.include?("compass")
      report_metric_data["status_compass_callback"] = 1
      if tpc_software_report_metric.status_tpc_service_callback == 1
        report_metric_data["status"] = TpcSoftwareReportMetric::Status_Success
      end
    else
      report_metric_data["status_tpc_service_callback"] = 1
      if tpc_software_report_metric.status_compass_callback == 1
        report_metric_data["status"] = TpcSoftwareReportMetric::Status_Success
      end
    end
    ActiveRecord::Base.transaction do
      tpc_software_report_metric.update!(report_metric_data)

      tpc_software_selection_report = TpcSoftwareSelectionReport.find_by(id: report_id)
      update_data = {}
      update_data[:code_count] = code_count unless code_count.nil?
      update_data[:license] = license unless license.nil?
      if update_data.present?
        tpc_software_selection_report.update!(update_data)
      end


      if report_metric_raw_data.length > 0
        metric_raw = TpcSoftwareReportMetricRaw.find_or_initialize_by(tpc_software_report_metric_id: tpc_software_report_metric.id)
        report_metric_raw_data[:tpc_software_report_metric_id] = tpc_software_report_metric.id
        report_metric_raw_data[:code_url] = tpc_software_report_metric.code_url
        report_metric_raw_data[:subject_id] = tpc_software_report_metric.subject_id
        metric_raw.update!(report_metric_raw_data)
      end
    end
  end

  def tpc_software_graduation_callback(command_list, scan_results, report_id, report_metric_id)
    code_count = nil
    license = nil
    # commands = ["scancode", "sonar-scanner", "binary-checker", "osv-scanner", "release-checker", "readme-checker",
    #             "maintainers-checker", "build-doc-checker", "api-doc-checker", "readme-opensource-checker", "compass"]
    tpc_software_graduation_report = TpcSoftwareGraduationReport.find_by(id: report_id)
    oh_commit_sha = tpc_software_graduation_report.oh_commit_sha
    metric_hash = Hash.new
    command_list.each do |command|
      case command
      when "scancode"
        if command_list.include?("oat-scanner")
          oat_status_code = scan_results.dig("oat-scanner").dig("status_code")
          oat_result = {}
          if oat_status_code == 200
            if command_list.include?("readme-opensource-checker")
              oat_result = scan_results.dig("oat-scanner").dig("No Readme.OpenSource") || {}
              metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_license(scan_results.dig(command) || {}, scan_results.dig("readme-opensource-checker") || {}, oat_result))
            end
            oat_result = scan_results.dig("oat-scanner").dig("License Not Compatible") || {}
            metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_license_compatibility(scan_results.dig(command) || {}, oat_result))
            if command_list.include?("changed-files-since-commit-detector")
              oat_result = scan_results.dig("oat-scanner").dig("Copyright Header Invalid") || {}
              metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_copyright_statement(scan_results.dig(command) || {}, scan_results.dig("changed-files-since-commit-detector") || {}, oh_commit_sha, oat_result))
            end
            oat_result = scan_results.dig("oat-scanner").dig("Import Invalid") || {}
            metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_import_valid(oat_result))

          else
            if command_list.include?("readme-opensource-checker")
              metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_license(scan_results.dig(command) || {}, scan_results.dig("readme-opensource-checker") || {}, nil))
            end
            metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_license_compatibility(scan_results.dig(command) || {}, nil))
            metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_copyright_statement(scan_results.dig(command) || {}, scan_results.dig("changed-files-since-commit-detector") || {}, oh_commit_sha, nil))
          end
        else
          # not include "oat-scanner"
          if command_list.include?("readme-opensource-checker")
            metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_license(scan_results.dig(command) || {}, scan_results.dig("readme-opensource-checker") || {}, nil))
          end
          metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_license_compatibility(scan_results.dig(command) || {}, nil))
          metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_copyright_statement(scan_results.dig(command) || {}, scan_results.dig("changed-files-since-commit-detector") || {}, oh_commit_sha, nil))
        end

        license = TpcSoftwareReportMetric.get_license(scan_results.dig(command) || {})
      when "sonar-scanner"
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_test_coverage(scan_results.dig(command) || {}))
        code_count = TpcSoftwareReportMetric.get_code_count(scan_results.dig(command) || {})
      when "binary-checker"
        if  command_list.include?("oat-scanner")
          oat_status_code = scan_results.dig("oat-scanner").dig("status_code")
          oat_result = {}
          if oat_status_code == 200
          oat_result =  scan_results.dig("oat-scanner").dig("Invalid File Type")||{}
          metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_security_binary_artifact(scan_results.dig(command) || {}, oat_result))
          else
            metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_security_binary_artifact(scan_results.dig(command) || {},nil))
          end
        else
          metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_security_binary_artifact(scan_results.dig(command) || {},nil))
        end
      when "osv-scanner"
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_security_vulnerability(scan_results.dig(command) || {}))
      when "release-checker"
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_security_package_sig(scan_results.dig(command) || {}))
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_lifecycle_release_note(scan_results.dig(command) || {}))
      when "readme-checker"
        if  command_list.include?("oat-scanner")
          oat_result =  scan_results.dig("oat-scanner").dig("No Readme")||{}
          metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_readme(scan_results.dig(command) || {},oat_result))
        else
          metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_readme(scan_results.dig(command) || {},nil))
        end

      when "maintainers-checker"
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_maintainer_doc(scan_results.dig(command) || {}))
      when "build-doc-checker"
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_build_doc(scan_results.dig(command) || {}))
      when "api-doc-checker"
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_interface_doc(scan_results.dig(command) || {}))
      when "compass"
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_compliance_dco(@project_url,oh_commit_sha))
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_issue_management(@project_url))
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_issue_response_ratio(@project_url))
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_issue_response_time(@project_url))
        metric_hash.merge!(TpcSoftwareGraduationReportMetric.get_ecology_code_review(@project_url))
      when "readme-opensource-checker"
        # no process
      when "changed-files-since-commit-detector"
        # no process
      when "oat-scanner"
        # no process
      else
        raise GraphQL::ExecutionError.new I18n.t('tpc.callback_command_not_exist', command: command)
      end
    end
    report_metric = TpcSoftwareGraduationReportMetric.find_by(id: report_metric_id)
    raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?

    report_metric_data = metric_hash.select { |key, _| !key.end_with?("_raw") }
    report_metric_raw_data = metric_hash.select { |key, _| key.end_with?("_raw") }
    if command_list.include?("compass")
      report_metric_data["status_compass_callback"] = 1
      if report_metric.status_tpc_service_callback == 1
        report_metric_data["status"] = TpcSoftwareGraduationReportMetric::Status_Success
      end
    else
      report_metric_data["status_tpc_service_callback"] = 1
      if report_metric.status_compass_callback == 1
        report_metric_data["status"] = TpcSoftwareGraduationReportMetric::Status_Success
      end
    end
    ActiveRecord::Base.transaction do
      report_metric.update!(report_metric_data)

      # tpc_software_graduation_report = TpcSoftwareGraduationReport.find_by(id: report_id)
      update_data = {}
      update_data[:code_count] = code_count unless code_count.nil?
      update_data[:license] = license unless license.nil?
      if update_data.present?
        tpc_software_graduation_report.update!(update_data)
      end


      if report_metric_raw_data.length > 0
        metric_raw = TpcSoftwareGraduationReportMetricRaw.find_or_initialize_by(tpc_software_graduation_report_metric_id: report_metric.id)
        report_metric_raw_data[:tpc_software_graduation_report_metric_id] = report_metric.id
        report_metric_raw_data[:code_url] = report_metric.code_url
        report_metric_raw_data[:subject_id] = report_metric.subject_id
        metric_raw.update!(report_metric_raw_data)
      end
    end
  end


  def tpc_service_token
    payload = {
      username: TPC_SERVICE_API_USERNAME,
      password: TPC_SERVICE_API_PASSWORD
    }
    result = base_post_request("auth", payload)
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
    result[:body]["access_token"]
  end

  def base_post_request(request_path, payload, token: nil)
    header = { 'Content-Type' => 'application/json' }
    if token
      header["Authorization"] = "JWT #{token}"
    end
    resp = RestClient::Request.new(
      method: :post,
      url: "#{TPC_SERVICE_API_ENDPOINT}/#{request_path}",
      payload: payload.to_json,
      headers: header,
      proxy: PROXY
    ).execute
    resp_hash = JSON.parse(resp.body)
    if resp.body.include?("error")
      { status: false, message: I18n.t('tpc.software_report_trigger_failed', reason: resp_hash['description']) }
    else
      { status: true, body: resp_hash }
    end
  rescue => ex
    { status: false, message: I18n.t('tpc.software_report_trigger_failed', reason: ex.message) }
  end

  def tpc_software_license_callback(command_list, scan_results, version_number)
    license = nil
    security = nil
    # commands = ["scancode","osv-scanner"]
    command_list.each do |command|
      case command
      when "scancode"
        license = get_opencheck_license(scan_results.dig(command) || {})
      when "osv-scanner"
        security = get_security(scan_results.dig(command) || {})
      else
        # raise GraphQL::ExecutionError.new I18n.t('tpc.callback_command_not_exist', command: command)
      end
    end
    OpencheckMetric.save_license(license, security, @project_url, version_number)
  end


  def save_opencheck_raw_callback(command_list, scan_results)
    command_list.each do |command|
      command_result = scan_results.dig(command) || {}
      OpencheckRaw.save_opencheck_raw(command, command_result, @project_url)
    end
  end

  def tpc_software_metrics_model_callback(metrics_model)
    if metrics_model&.any?
      opts = {
        repo_url: @project_url,
        opencheck_raw: false,
        opencheck_raw_param: {},
        raw: false,
        enrich: false,
        license: false,
        identities_load: false,
        identities_merge: false,
        activity: false,
        community: false,
        codequality: false,
        group_activity: false,
        domain_persona: false,
        milestone_persona: false,
        role_persona: false
      }
      metrics_model.each do |key|
        opts[key.to_sym] = true
      end

      result = AnalyzeServer.new(opts).execute_tpc
      Rails.logger.info("analyze metric model info: #{result}")
      raise GraphQL::ExecutionError.new result[:message] unless result[:status]
    end

  end


  def get_opencheck_license(scancode_result)
    license_list = []
    osi_license_list = []
    non_osi_license_list = []

    license_db_data = TpcSoftwareReportMetric.get_license_data

    raw_data = (scancode_result.dig("files") || []).map do |file|
      keys_to_select = %w[path type detected_license_expression detected_license_expression_spdx]
      file_type = file.dig("type") || ""
      from_file_split = (file.dig("path") || "").downcase.split("/")
      if file_type == "file" &&
        file.dig("detected_license_expression") &&
        (from_file_split.length == 2 || (from_file_split.length >= 2 && from_file_split[1] == "license")) &&
        !(from_file_split.length == 2 && %w[readme.opensource oat.xml].include?(from_file_split.last))
        file.select { |key, _| keys_to_select.include?(key) }
      end
    end.compact

    replacements = {
      "(" => "",
      ")" => "",
      "and" => "",
      "or" => ""
    }
    raw_data.each do |raw|
      license_expression = raw['detected_license_expression']
      license_expression = license_expression.strip.downcase
      license_expression = license_expression.gsub(Regexp.union(replacements.keys), replacements)
      license_expression_list = license_expression.split
      license_expression_list.each do |license_expression_item|
        unless license_expression_item.include?("unknown")
          license_list << license_expression_item
          category = license_db_data.dig(license_expression_item, :category)
          if category
            case category
            when "Permissive"
              osi_license_list << license_expression_item
            when "Copyleft Limited"
              osi_license_list << license_expression_item
            else
              osi_license_list << license_expression_item
            end
          else
            non_osi_license_list << license_expression_item
          end
        end
      end
    end

    {
      license_list: license_list.uniq,
      osi_license_list: osi_license_list.uniq,
      non_osi_licenses: non_osi_license_list.uniq
    }

  end

  def get_security(osv_scanner_result)
    details = []
    (osv_scanner_result.dig("results") || []).each do |item|
      packages = item.dig("packages") || []
      packages.each do |package|
        vulnerabilities = (package.dig("vulnerabilities") || []).flat_map do |vulnerability|
          fixed_version = (vulnerability.dig("affected") || []).flat_map do |affected|
            (affected.dig("ranges") || []).flat_map do |range|
              (range.dig("events") || []).filter_map { |event| event["fixed"] if event.key?("fixed") }
            end
          end.uniq

          severity = vulnerability.dig("database_specific", "severity") || ""
          {
            published: vulnerability.dig("published"),
            aliases: vulnerability.dig("aliases") || [],
            severity: severity,
            fixed_version: fixed_version
          }
        end

        if vulnerabilities.any?
          details << {
            package_name: package.dig("package", "name"),
            package_version: package.dig("package", "version"),
            vulnerabilities: vulnerabilities.uniq
          }
        end
      end
    end
    details
  end

end
