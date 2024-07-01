# frozen_string_literal: true

class TpcSoftwareMetricServer

  include Common
  include CompassUtils

  DEFAULT_HOST = ENV.fetch('DEFAULT_HOST')

  TPC_SERVICE_API_ENDPOINT = ENV.fetch('TPC_SERVICE_API_ENDPOINT')
  TPC_SERVICE_API_USERNAME = ENV.fetch('TPC_SERVICE_API_USERNAME')
  TPC_SERVICE_API_PASSWORD = ENV.fetch('TPC_SERVICE_API_PASSWORD')
  TPC_SERVICE_CALLBACK_URL = "#{DEFAULT_HOST}/api/tpc_software_callback"

  @@license_conflict_data = nil



  def initialize(opts = {})
    @project_url = opts[:project_url]
  end

  def self.check_url(url)
    if url.nil?
      false
    end
    proxy_options = url.include?('github.com') ? { proxy: PROXY } : {}
    resp = RestClient::Request.new(
      method: :get,
      url: url,
      **proxy_options
    ).execute
    resp.code == 200 ? true : false
  rescue => ex
    false
  end

  def analyze_metric_by_compass(report_id, report_metric_id)
    result = AnalyzeServer.new(
      {
        repo_url: @project_url,
        callback: {
          hook_url: TPC_SERVICE_CALLBACK_URL,
          params: {
            callback_type: "tpc_software_callback",
            task_metadata: {
              report_id: report_id,
              report_metric_id: report_metric_id
            }
          }
        }
      }
    ).simple_execute
    Rails.logger.info("analyze metric by compass info: #{result}")
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
  end

  def analyze_metric_by_tpc_service(report_id, report_metric_id)
    token = tpc_service_token
    commands = ["osv-scanner", "scancode", "binary-checker", "signature-checker", "sonar-scanner"]
    payload = {
      commands: commands,
      project_url: "#{@project_url}.git",
      callback_url: TPC_SERVICE_CALLBACK_URL,
      task_metadata: {
        report_id: report_id,
        report_metric_id: report_metric_id
      }
    }
    result = base_post_request("opencheck", payload, token: token)
    Rails.logger.info("analyze metric by tpc service info: #{result}")
    raise GraphQL::ExecutionError.new result[:message] unless result[:status]
  end


  def tpc_software_callback(command_list, scan_results, task_metadata)
    code_count = nil
    license = nil

    # commands = ["osv-scanner", "scancode", "binary-checker", "signature-checker", "sonar-scanner", "compass"]
    metric_hash = Hash.new
    command_list.each do |command|
      case command
      when "osv-scanner"
        metric_hash.merge!(get_security_vulnerability(scan_results.dig(command)))
      when "scancode"
        metric_hash.merge!(get_compliance_license(scan_results.dig(command)))
        metric_hash.merge!(get_compliance_license_compatibility(scan_results.dig(command)))
        license = get_license(scan_results.dig(command))
      when "binary-checker"
        metric_hash.merge!(get_security_binary_artifact(scan_results.dig(command)))
      when "signature-checker"
        metric_hash.merge!(get_compliance_package_sig(scan_results.dig(command)))
      when "sonar-scanner"
        metric_hash.merge!(get_ecology_software_quality(scan_results.dig(command)))
      when "compass"
        metric_hash.merge!(get_compliance_dco)
        metric_hash.merge!(get_ecology_code_maintenance)
        metric_hash.merge!(get_ecology_community_support)
        metric_hash.merge!(get_security_history_vulnerability)
        metric_hash.merge!(get_lifecycle_version_lifecycle)
        code_count = get_code_count
      end
    end
    report_metric_id = task_metadata["report_metric_id"]
    tpc_software_report_metric = TpcSoftwareReportMetric.find_by(id: report_metric_id)
    report_metric_data = metric_hash
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

      tpc_software_selection_report = TpcSoftwareSelectionReport.find_by(id: task_metadata["report_id"])
      update_data = {}
      update_data[:code_count] = code_count unless code_count.nil?
      update_data[:license] = license unless license.nil?
      if update_data.present?
        tpc_software_selection_report.update!(update_data)
      end
    end
  end


  def self.read_license_conflict_data
    data_hash = {}
    row_header_license = []

    license_xlsx = Roo::Excelx.new(Rails.root.join('app', 'assets', 'source', 'license_compatibility_source_code.xlsx').to_s)

    license_xlsx.sheet(0).each_with_index do |row, index|
      if index == 0
        row_header_license = row.map(&:to_s)
      else
        header = row[0].to_s.strip

        row_list = []
        row[1..-1].each_with_index do |cell, cell_index|
          cell_value = cell.to_s.strip
          if !cell_value.empty? && cell_value.include?("冲突")
            row_list.push(row_header_license[cell_index + 1].downcase)
          end
        end

        data_hash[header.downcase] = row_list
      end
    end
    data_hash
  end

  def self.license_conflict_data
    if @@license_conflict_data.nil?
      @@license_conflict_data = self.read_license_conflict_data
    end
    @@license_conflict_data
  end


  private

  def get_security_vulnerability(osv_scanner_result)
    # Check for publicly disclosed unfixed vulnerabilities in imported software and dependency source code:
    # 10 points if met, 0 points if not met.
    details = []
    (osv_scanner_result.dig("results") || []).each do |item|
      packages = item.dig("packages") || []
      packages.each do |package|
        vulnerabilities = (package.dig("vulnerabilities") || []).flat_map do |vulnerability|
          (vulnerability.dig("aliases") || [])
        end

        if vulnerabilities.any?
          details << {
            package_name: package.dig("package", "name"),
            package_version: package.dig("package", "version"),
            vulnerabilities: vulnerabilities.uniq.take(5)
          }
        end
      end
    end
    score = 0
    if details.length == 0
      score = 10
    end
    { security_vulnerability: score, security_vulnerability_detail: details.take(3).to_json }
  end


  def get_security_binary_artifact(binary_checker_result)
    binary_archive_list = binary_checker_result.dig("binary_archive_list") || []

    score = 0
    if binary_archive_list.length == 0
      score = 10
    end
    { security_binary_artifact: score, security_binary_artifact_detail: binary_archive_list.take(5).to_json }
  end

  def get_compliance_license(scancode_result)
    # Standard location with license on the admission list: 10 points;
    # Non-standard location with license on the admission list: 8 points;
    # License not on the admission list: 6 points;
    # No license: 0 points.

    is_standard_license_location = false
    license_access_list = []
    license_non_access_list = []

    subject_licenses = SubjectLicense.all


    (scancode_result.dig("license_detections") || []).each do |license_detection|
      (license_detection.dig("license_expression") || "").split(" AND ").each do |license_expression|
        subject_licenses.each do |subject_license|
          if subject_license.license.downcase.include?(license_expression.downcase)
            license_access_list << license_expression
            break
          end
        end
        unless license_access_list.include?(license_expression)
          license_non_access_list << license_expression
        end
      end
    end

    standard_license_location_list = %W[#{@project_url.split('/')[-1]}/license #{@project_url.split('/')[-1]}/license.txt]
    (scancode_result.dig("files") || []).each do |file|
      if standard_license_location_list.include?(file.dig("path")) && (file.dig("license_detections") || []).any?
        is_standard_license_location = true
        break
      end
    end

    score = 0
    if (license_access_list + license_non_access_list).any?
      if license_non_access_list.length == 0
        if is_standard_license_location
          score = 10
        else
          score = 8
        end
      else
        score = 6
      end
    end
    detail = {
      license_access_list: license_access_list.uniq.take(5),
      license_non_access_list: license_non_access_list.uniq.take(5)
    }
    { compliance_license: score, compliance_license_detail: detail.to_json }
  end

  def get_compliance_license_compatibility(scancode_result)
    license_conflict_data = self.class.license_conflict_data

    check_license_list = []
    (scancode_result.dig("license_detections") || []).each do |license_detection|
      (license_detection.dig("license_expression") || "").split("AND").each do |license_expression|
          check_license_list << license_expression.downcase
      end
    end

    conflict_list = []
    check_license_list.each_with_index do |check_license, index|
      if license_conflict_data.key?(check_license)
        license_conflict_list = license_conflict_data[check_license] & check_license_list[index..-1]
        if license_conflict_list.any?
          conflict_list << {
            license: check_license,
            license_conflict_list: license_conflict_list.take(5)
          }
        end
      end
    end

    score = 0
    if conflict_list.length == 0
      score = 10
    end
    { compliance_license_compatibility: score, compliance_license_compatibility_detail: conflict_list.take(3).to_json }
  end

  def get_compliance_package_sig(signature_checker_result)
    signature_file_list = signature_checker_result.dig("signature_file_list") || []

    score = 6
    if signature_file_list.length > 0
      score = 10
    end
    { compliance_package_sig: score, compliance_package_sig_detail: signature_file_list.take(5).to_json }
  end

  def get_ecology_software_quality(sonar_scanner_result)
    measures = sonar_scanner_result.dig("component", "measures")
    duplication_score = 0
    duplication_ratio = nil
    coverage_score = 0
    coverage_ratio = nil
    measures.each do |measure|
      if measure.dig("metric") == "duplicated_lines_density"
        score_ranges = {
          (0..2) => 10,
          (3..4) => 8,
          (5..9) => 6,
          (10..19) => 4,
          (20..100) => 2
        }
        duplication_ratio = measure.dig("value").to_i
        duplication_score = score_ranges.find { |range, _| range.include?(duplication_ratio) }&.last
      elsif measure.dig("metric") == "coverage"
        score_ranges = {
          (0..29) => 2,
          (30..49) => 4,
          (50..69) => 6,
          (70..79) => 8,
          (80..100) => 10
        }
        coverage_ratio = measure.dig("value").to_i
        coverage_score = score_ranges.find { |range, _| range.include?(coverage_ratio) }&.last
      end
    end
    score = (duplication_score + coverage_score) / 2.0
    detail = {
      duplication_score: duplication_score,
      duplication_ratio: duplication_ratio,
      coverage_score: coverage_score,
      coverage_ratio: coverage_ratio
    }
    { ecology_software_quality: score, ecology_software_quality_detail: detail.to_json }
  end

  def get_compliance_dco
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(@project_url, "repo", GiteeGitEnrich, GithubGitEnrich)
    base = indexer.must(terms: { tag: repo_urls.map { |element| element + ".git" } })
                  .aggregate({ count: { cardinality: { field: "uuid" } }})
                  .per(0)

    commit_count = base.execute.aggregations.dig('count', 'value')
    commit_dco_count = base.must(wildcard: { author_email: { value: "*Signed-off-by*" } })
                                  .execute.aggregations.dig('count', 'value')
    if commit_count == 0
      score = 0
    elsif commit_dco_count == 0
      score = 6
    elsif commit_count == commit_dco_count
      score = 10
    else
      score = 8
    end
    detail = {
      commit_count: commit_count,
      commit_dco_count: commit_dco_count,
    }
    { compliance_dco: score, compliance_dco_detail: detail.to_json }
  end

  def get_ecology_code_maintenance
    begin_date = 1.year.ago
    end_date = Time.current
    score = ActivityMetric.aggregate({ avg_score: { avg: { field: ActivityMetric::main_score } }})
                              .must(match_phrase: { 'label.keyword': @project_url })
                              .must(match_phrase: { 'level.keyword': "repo" })
                              .per(0)
                              .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                              .execute
                              .aggregations.dig('avg_score', 'value') || 0

    if score > 0
      score = (ActivityMetric.scaled_value(nil, target_value: score) / 10).ceil
    end
    { ecology_code_maintenance: score, ecology_code_maintenance_detail: nil }
  end

  def get_ecology_community_support
    begin_date = 1.year.ago
    end_date = Time.current
    score = CommunityMetric.aggregate({ avg_score: { avg: { field: CommunityMetric::main_score } }})
                              .must(match_phrase: { 'label.keyword': @project_url })
                              .must(match_phrase: { 'level.keyword': "repo" })
                              .per(0)
                              .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                              .execute
                              .aggregations.dig('avg_score', 'value') || 0
    if score > 0
      score = (CommunityMetric.scaled_value(nil, target_value: score) / 10).ceil
    end
    { ecology_community_support: score, ecology_community_support_detail: nil }
  end

  def get_security_history_vulnerability
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(@project_url, "repo", GiteeGitEnrich, GithubGitEnrich)
    resp = indexer.must(terms: { tag: repo_urls.map { |element| element + ".git" } })
                  .per(1)
                  .sort(grimoire_creation_date: "desc")
                  .execute
                  .raw_response
    hits = resp.dig("hits", "hits") || []
    if hits.length == 0
      score = 0
      detail = {}
    else
      commit_hash = hits[0].dig("_source", "hash") || ""
      osv_query_data = osv_query(commit_hash)
      vulns = osv_query_data.dig("vulns") || []
      vulnerabilities = vulns.map do |vuln|
        {
          vulnerability: vuln["id"],
          summary: vuln["summary"]
        }
      end
      if vulnerabilities.length == 0
        score = 10
      elsif 1 <= vulnerabilities.length && vulnerabilities.length <=5
        score = 8
      else
        score = 6
      end
      detail = vulnerabilities.take(10)
    end
    { security_history_vulnerability: score, security_history_vulnerability_detail: detail.to_json }
  end

  def get_lifecycle_version_lifecycle
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(@project_url, "repo", GiteeRepoEnrich, GithubRepoEnrich)
    resp = indexer.must(terms: { tag: repo_urls })
                  .per(1)
                  .sort(grimoire_creation_date: "desc")
                  .execute
                  .raw_response
    hits = resp.dig("hits", "hits") || []
    if hits.length == 0
      score = 0
      detail = {}
    else
      archived = hits[0].dig("_source", "archived") || false
      releases = (hits[0].dig("_source", "releases") || []).sort_by { |hash| hash["created_at"] }.reverse

      if archived
        score = 0
      elsif releases.length == 0
        score = 4
      elsif 2.year.ago <= DateTime.parse(release.dig("created_at"))
        score = 10
      else
        score = 6
      end
      detail = {
        archived: archived,
        latest_version_name: releases.length > 0 ? releases.first.dig("tag_name") : nil,
        latest_version_created_at: releases.length > 0 ? releases.first.dig("created_at") : nil,
      }
    end
    { lifecycle_version_lifecycle: score, lifecycle_version_lifecycle_detail: detail.to_json }
  end

  def osv_query(commit_hash)
    resp = RestClient::Request.new(
      method: :post,
      url: "https://api.osv.dev/v1/query",
      payload: {
        commit: commit_hash
      }.to_json,
      headers: { 'Content-Type' => 'application/json' },
      ).execute
    JSON.parse(resp.body)
  end


  def get_code_count
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(@project_url, "repo", GiteeGitEnrich, GithubGitEnrich)
    resp = indexer.must(terms: { tag: repo_urls.map { |element| element + ".git" } })
                  .aggregate(
                    lines_added: { sum: { field: "lines_added" } },
                    lines_removed: { sum: { field: "lines_removed" } }
                  )
                  .per(0)
                  .execute
                  .raw_response
    lines_added = resp.dig("aggregations", "lines_added", "value") || 0
    lines_removed = resp.dig("aggregations", "lines_removed", "value") || 0
    code_count = lines_added + lines_removed
    if code_count < 0
      code_count = 0
    end
    code_count
  end

  def get_license(scancode_result)
    license_detections = scancode_result.dig("license_detections") || []
    unless license_detections&.any?
      return nil
    end

    standard_license_location = "#{@project_url.split("/")[-1]}/License.txt"
    license_detections.each do |license_detection|
      (license_detection.dig("reference_matches") || []).each do |reference_match|
        if reference_match.dig("from_file") == standard_license_location
          return reference_match.dig("license_expression_spdx")
        end
      end
    end
    license_detections.first.dig("license_expression_spdx") || license_detections.first.dig("license_expression") || nil
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

end
