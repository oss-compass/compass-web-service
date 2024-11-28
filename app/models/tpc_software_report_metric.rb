# == Schema Information
#
# Table name: tpc_software_report_metrics
#
#  id                                       :bigint           not null, primary key
#  code_url                                 :string(255)      not null
#  status                                   :string(255)      not null
#  status_compass_callback                  :integer          not null
#  status_tpc_service_callback              :integer          not null
#  version                                  :integer          not null
#  tpc_software_report_id                   :integer          not null
#  tpc_software_report_type                 :string(255)      not null
#  subject_id                               :integer          not null
#  user_id                                  :integer          not null
#  base_repo_name                           :integer
#  base_website_url                         :integer
#  base_code_url                            :integer
#  compliance_license                       :integer
#  compliance_dco                           :integer
#  compliance_package_sig                   :integer
#  compliance_license_compatibility         :integer
#  ecology_dependency_acquisition           :integer
#  ecology_code_maintenance                 :integer
#  ecology_community_support                :integer
#  ecology_adoption_analysis                :integer
#  ecology_software_quality                 :integer
#  ecology_patent_risk                      :integer
#  lifecycle_version_normalization          :integer
#  lifecycle_version_number                 :integer
#  lifecycle_version_lifecycle              :integer
#  security_binary_artifact                 :integer
#  security_vulnerability                   :integer
#  security_vulnerability_response          :integer
#  security_vulnerability_disclosure        :integer
#  security_history_vulnerability           :integer
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  base_repo_name_detail                    :string(500)
#  base_website_url_detail                  :string(500)
#  base_code_url_detail                     :string(500)
#  compliance_license_detail                :string(500)
#  compliance_dco_detail                    :string(500)
#  compliance_package_sig_detail            :string(500)
#  compliance_license_compatibility_detail  :string(500)
#  ecology_dependency_acquisition_detail    :string(500)
#  ecology_code_maintenance_detail          :string(500)
#  ecology_community_support_detail         :string(500)
#  ecology_adoption_analysis_detail         :string(500)
#  ecology_software_quality_detail          :string(500)
#  ecology_patent_risk_detail               :string(500)
#  lifecycle_version_normalization_detail   :string(500)
#  lifecycle_version_number_detail          :string(500)
#  lifecycle_version_lifecycle_detail       :string(500)
#  security_binary_artifact_detail          :string(500)
#  security_vulnerability_detail            :string(500)
#  security_vulnerability_response_detail   :string(500)
#  security_vulnerability_disclosure_detail :string(500)
#  security_history_vulnerability_detail    :string(5000)
#
class TpcSoftwareReportMetric < ApplicationRecord

  include Common
  extend CompassUtils

  belongs_to :tpc_software_report, polymorphic: true
  belongs_to :subject
  belongs_to :user
  has_one :tpc_software_report_metric_raw
  has_many :tpc_software_comments, as: :tpc_software, dependent: :destroy
  has_many :tpc_software_comment_states, as: :tpc_software, dependent: :destroy

  Report_Type_Selection = 'TpcSoftwareSelectionReport'

  Status_Progress = 'progress'
  Status_Again_Progress = 'again_progress'
  Status_Success = 'success'

  Version_History = 0
  Version_Default = 1

  @@license_conflict_data = nil
  @@license_data = nil

  def report_score

    compliance_metric_score = [compliance_license, compliance_dco, compliance_license_compatibility, ecology_patent_risk]
    compliance_metric_score_filter = compliance_metric_score.compact.reject { |element| element == -1 }
    compliance_score = compliance_metric_score_filter.sum(0) * 10 / compliance_metric_score_filter.size

    ecology_metric_score = [ecology_dependency_acquisition, ecology_code_maintenance, ecology_community_support,
                               ecology_adoption_analysis, get_ecology_software_quality, get_ecology_adaptation_method]
    ecology_metric_score_filter = ecology_metric_score.compact.reject { |element| element == -1 }
    ecology_score = ecology_metric_score_filter.sum(0) * 10 / ecology_metric_score_filter.size

    lifecycle_metric_score = [lifecycle_version_lifecycle]
    lifecycle_metric_score_filter = lifecycle_metric_score.compact.reject { |element| element == -1 }
    lifecycle_score = lifecycle_metric_score_filter.sum(0) * 10 / lifecycle_metric_score_filter.size

    security_metric_score = [security_binary_artifact, security_vulnerability, security_vulnerability_response]
    security_metric_score_filter = security_metric_score.compact.reject { |element| element == -1 }
    security_score = security_metric_score_filter.sum(0) * 10 / security_metric_score_filter.size

    total_score = [compliance_score, ecology_score, lifecycle_score, security_score]
    total_score = total_score.sum(0) / total_score.size

    [total_score, compliance_score, ecology_score, lifecycle_score, security_score]
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

  def self.get_security_vulnerability(osv_scanner_result)
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
            vulnerabilities: vulnerabilities.uniq.take(1)
          }
        end
      end
    end
    score = 0
    if details.length == 0
      score = 10
    end
    {
      security_vulnerability: score,
      security_vulnerability_detail: details.take(1).to_json,
      security_vulnerability_raw: details.take(5).to_json
    }
  end

  def self.get_compliance_license(scancode_result)
    license_list = []
    osi_permissive_license_list = []
    osi_copyleft_limited_license_list = []
    osi_free_restricted_license_list = []
    non_osi_license_list = []

    license_db_data = get_license_data

    raw_data = (scancode_result.dig("files") || []).map do |file|
      keys_to_select = %w[path type detected_license_expression detected_license_expression_spdx]
      file_type = file.dig("type") || ""
      from_file_split = (file.dig("path") || "").downcase.split("/")
      if file_type == "file" && file.dig("detected_license_expression") &&
        (from_file_split.length == 2 || from_file_split.length >= 2 && from_file_split[1] == "license")
        file.select { |key, _| keys_to_select.include?(key) }
      end
    end.compact

    raw_data.each do |raw|
      license_expression = raw['detected_license_expression']
      license_expression = license_expression.strip.downcase
      license_list << license_expression
      category = license_db_data.dig(license_expression, :category)
      if category
        case category
        when "Permissive"
          osi_permissive_license_list << license_expression
        when "Copyleft Limited"
          osi_copyleft_limited_license_list << license_expression
        else
          osi_free_restricted_license_list << license_expression
        end
      else
        non_osi_license_list << license_expression
      end
    end

    score = 0
    if license_list.length > 0
      if non_osi_license_list.length > 0
        score = 0
      elsif osi_free_restricted_license_list.length > 0
        score = 6
      elsif osi_copyleft_limited_license_list.length > 0
        score = 8
      elsif osi_permissive_license_list.length > 0
        score = 10
      end
    end
    detail = {
      osi_permissive_licenses: osi_permissive_license_list.uniq.take(1),
      osi_copyleft_limited_licenses: osi_copyleft_limited_license_list.uniq.take(1),
      osi_free_restricted_licenses: osi_free_restricted_license_list.uniq.take(1),
      non_osi_licenses: non_osi_license_list.uniq.take(1)
    }

    {
      compliance_license: score,
      compliance_license_detail: detail.to_json,
      compliance_license_raw: raw_data.take(30).to_json
    }
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

  def self.get_license_conflict_data
    if @@license_conflict_data.nil?
      @@license_conflict_data = read_license_conflict_data
    end
    @@license_conflict_data
  end

  def self.read_license_data
    data_hash = {}

    scancode_licenses_data = File.read(Rails.root.join('app', 'assets', 'source', 'scancode_licenses.json'))
    scancode_licenses_json = JSON.parse(scancode_licenses_data)

    spdx_licenses_data = File.read(Rails.root.join('app', 'assets', 'source', 'spdx_licenses.json'))
    spdx_licenses_json = JSON.parse(spdx_licenses_data)
    spdx_license_hash = spdx_licenses_json["licenses"].map { |spdx| [spdx['licenseId'], spdx] }.to_h

    scancode_licenses_json.each do |scancode|
      spdx_license_key  = scancode['spdx_license_key']
      if spdx_license_hash.dig(spdx_license_key, 'isOsiApproved')
        data_hash[scancode['license_key']] = {
          license_key: scancode['license_key'],
          category: scancode['category'],
          spdx_license_key: scancode['spdx_license_key'],
          is_osi_approved: spdx_license_hash.dig(spdx_license_key, 'isOsiApproved')
        }
      end
    end
    data_hash
  end

  def self.get_license_data
    if @@license_data.nil?
      @@license_data = read_license_data
    end
    @@license_data
  end

  def self.get_compliance_license_compatibility(scancode_result)
    license_conflict_data = get_license_conflict_data

    check_license_list = []
    (scancode_result.dig("license_detections") || []).each do |license_detection|
      (license_detection.dig("license_expression") || "").split(/ AND | OR /).each do |license_expression|
        check_license_list << license_expression.strip.downcase
      end
    end

    conflict_list = []
    check_license_list = check_license_list.uniq
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

    raw_data = (scancode_result.dig("license_detections") || []).flat_map do |license_detection|
      (license_detection.dig("reference_matches") || []).map do |reference_match|
        keys_to_select = %w[license_expression license_expression_spdx from_file start_line end_line matcher score]
        reference_match.select { |key, _| keys_to_select.include?(key) }
      end
    end
    {
      compliance_license_compatibility: score,
      compliance_license_compatibility_detail: conflict_list.take(3).to_json,
      compliance_license_compatibility_raw: raw_data.take(30).to_json
    }
  end

  def self.get_security_binary_artifact(binary_checker_result)
    binary_archive_list = binary_checker_result.dig("binary_archive_list") || []

    score = 0
    if binary_archive_list.length == 0
      score = 10
    end

    raw_data = {
      "binary_file_list": (binary_checker_result.dig("binary_archive_list") || []).take(5),
      "binary_archive_list": (binary_checker_result.dig("binary_archive_list") || []).take(5),
    }

    {
      security_binary_artifact: score,
      security_binary_artifact_detail: binary_archive_list.take(1).to_json,
      security_binary_artifact_raw: raw_data.to_json
    }
  end

  def self.get_ecology_software_quality(sonar_scanner_result)
    measures = sonar_scanner_result.dig("component", "measures") || []
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
          (20..99) => 2,
          (100..100) => 0
        }
        duplication_ratio = measure.dig("value").to_i
        duplication_score = score_ranges.find { |range, _| range.include?(duplication_ratio) }&.last
      elsif measure.dig("metric") == "coverage"
        score_ranges = {
          (0..0) => 0,
          (1..29) => 2,
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
    {
      ecology_software_quality: score,
      ecology_software_quality_detail: detail.to_json,
      ecology_software_quality_raw: sonar_scanner_result.to_json
    }
  end

  def self.get_compliance_dco(project_url,oh_commit_sha)
    indexer, repo_urls =  select_idx_repos_by_lablel_and_level(project_url, "repo", GiteeGitEnrich, GithubGitEnrich)


    commit_time_query = indexer.must(term: { "hash.keyword": oh_commit_sha })
                               .aggregate({ commit_time: { min: { field: "author_date" } } })
                               .per(0)
    commit_time = commit_time_query.execute.aggregations.dig('commit_time', 'value')

    if commit_time.nil?
      return { compliance_dco: 6, compliance_dco_detail: { commit_count: 0, commit_dco_count: 0 }.to_json }
    end

    base = indexer.must(terms: { tag: repo_urls.map { |element| element + ".git" } })
                  .must(range: { commit_date: { gte: commit_time } })
                  .aggregate({ count: { cardinality: { field: "uuid" } }})
                  .per(0)

    commit_count = base.execute.aggregations.dig('count', 'value')
    commit_dco_count = base.must(wildcard: { message: { value: "*Signed-off-by*" } })
                           .execute.aggregations.dig('count', 'value')
    if commit_count == 0 || commit_dco_count == 0
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


  def self.get_ecology_code_maintenance(project_url)
    begin_date = 1.year.ago
    end_date = Time.current
    score = ActivityMetric.aggregate({ avg_score: { avg: { field: ActivityMetric::main_score } }})
                          .must(match_phrase: { 'label.keyword': project_url })
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

  def self.get_ecology_community_support(project_url)
    begin_date = 1.year.ago
    end_date = Time.current
    score = CommunityMetric.aggregate({ avg_score: { avg: { field: CommunityMetric::main_score } }})
                           .must(match_phrase: { 'label.keyword': project_url })
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

  def self.get_security_history_vulnerability(project_url)
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(project_url, "repo", GiteeRepoEnrich, GithubRepoEnrich)
    resp = indexer.must(terms: { tag: repo_urls })
                  .per(1)
                  .sort(grimoire_creation_date: "desc")
                  .execute
                  .raw_response
    hits = resp.dig("hits", "hits") || []
    score = 0
    detail = []
    raw_data = []
    if hits.length > 0
      releases = hits[0].dig("_source", "releases") || []
      package_name = project_url.split("/").last
      past_time = 3.year.ago
      vulnerabilities = []
      raw_data = []
      releases.each do |release|
        created_at = DateTime.parse(release.dig("created_at"))
        if past_time <= created_at
          osv_query_data = self.osv_query(package_name, release.dig("tag_name"))
          (osv_query_data.dig("vulns") || []).each do |vuln|
            vulnerabilities << {
              vulnerability: vuln.dig("id"),
              summary: vuln.dig("summary")
            }
            raw_data << {
              vulnerability: vuln.dig("id"),
              summary: vuln.dig("summary"),
              details: vuln.dig("details"),
              modified: vuln.dig("modified"),
              published: vuln.dig("published")
            }
          end
        end
      end
      if vulnerabilities.length == 0
        score = 10
      elsif 1 <= vulnerabilities.length && vulnerabilities.length <=5
        score = 8
      else
        score = 6
      end
      detail = vulnerabilities.take(8)
    end
    {
      security_history_vulnerability: score,
      security_history_vulnerability_detail: detail.to_json,
      security_history_vulnerability_raw: raw_data.take(50).to_json
    }
  end

  def self.get_lifecycle_version_lifecycle(project_url)
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(project_url, "repo", GiteeRepoEnrich, GithubRepoEnrich)
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
      elsif 2.year.ago <= DateTime.parse(releases.first.dig("created_at"))
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

  def self.osv_query(package_name, version)
    resp = RestClient::Request.new(
      method: :post,
      url: "https://api.osv.dev/v1/query",
      payload: {
        package: {
          name: package_name
        },
        version: version
      }.to_json,
      headers: { 'Content-Type' => 'application/json' },
      ).execute
    JSON.parse(resp.body)
  end

  def self.get_code_count(sonar_scanner_result)
    measures = sonar_scanner_result.dig("component", "measures") || []
    code_count = 0
    measures.each do |measure|
      if measure.dig("metric") == "lines"
        code_count = measure.dig("value").to_i
      end
    end
    code_count
  end

  def self.get_license(scancode_result)
    root_directory_license = []
    sub_directory_license = []

    (scancode_result.dig("files") || []).each do |file|
      file_type = file.dig("type") || ""
      from_file_split = (file.dig("path") || "").downcase.split("/")
      if file_type == "file" && file.dig("detected_license_expression")
        if from_file_split.length == 2
          root_directory_license << file.dig("detected_license_expression")
        end
        if from_file_split.length > 2 && from_file_split[1] == "license"
          sub_directory_license << file.dig("detected_license_expression")
        end
      end
    end
    return root_directory_license.first || sub_directory_license.first || nil
  end

  def self.get_ecology_dependency_acquisition(dependency_checker_result)
    packages_without_license_list = dependency_checker_result.dig("packages_without_license_detect") || []
    score = packages_without_license_list.length == 0 ? 10 : 0
    detail = packages_without_license_list.take(5)

    raw_data = {
      "packages_with_license_detect": (dependency_checker_result.dig("packages_with_license_detect") || []).take(30),
      "packages_without_license_detect": (dependency_checker_result.dig("packages_without_license_detect") || []).take(30)
    }

    {
      ecology_dependency_acquisition: score,
      ecology_dependency_acquisition_detail: detail.to_json,
      ecology_dependency_acquisition_raw: raw_data.to_json
    }
  end

  def get_ecology_adaptation_method_detail
    query_data = TpcSoftwareSelectionReport.find_by(id: tpc_software_report_id)
    if query_data.present?
      return query_data.adaptation_method
    end
    nil
  end

  def get_ecology_adaptation_method
    adaptation_method = get_ecology_adaptation_method_detail
    score = -1
    if adaptation_method.present?
      case adaptation_method
      when "JS/TS适配"
        score = 10
      when "C/C++库移植"
        score = 10
      when "参考"
        score = 8
      when "Java库重写"
        score = 6
      else
        score = -1
      end
    end
    score
  end

  def get_ecology_software_quality
    quality_detail = ecology_software_quality_detail.present? ? JSON.parse(ecology_software_quality_detail) : {}
    if quality_detail.dig("duplication_ratio").nil? || quality_detail.dig("coverage_ratio").nil?
      -1
    else
      ecology_software_quality
    end
  end

end
