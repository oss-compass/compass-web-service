# == Schema Information
#
# Table name: tpc_software_graduation_report_metrics
#
#  id                                                :bigint           not null, primary key
#  code_url                                          :string(255)      not null
#  status                                            :string(255)      not null
#  status_compass_callback                           :integer          not null
#  status_tpc_service_callback                       :integer          not null
#  version                                           :integer          not null
#  tpc_software_graduation_report_id                 :integer          not null
#  subject_id                                        :integer          not null
#  user_id                                           :integer          not null
#  compliance_license                                :integer
#  compliance_license_detail                         :string(500)
#  compliance_dco                                    :integer
#  compliance_dco_detail                             :string(500)
#  compliance_license_compatibility                  :integer
#  compliance_license_compatibility_detail           :string(500)
#  compliance_copyright_statement                    :integer
#  compliance_copyright_statement_detail             :string(500)
#  compliance_copyright_statement_anti_tamper        :integer
#  compliance_copyright_statement_anti_tamper_detail :string(500)
#  ecology_readme                                    :integer
#  ecology_readme_detail                             :string(500)
#  ecology_build_doc                                 :integer
#  ecology_build_doc_detail                          :string(500)
#  ecology_interface_doc                             :integer
#  ecology_interface_doc_detail                      :string(500)
#  ecology_issue_management                          :integer
#  ecology_issue_management_detail                   :string(500)
#  ecology_issue_response_ratio                      :integer
#  ecology_issue_response_ratio_detail               :string(500)
#  ecology_issue_response_time                       :integer
#  ecology_issue_response_time_detail                :string(500)
#  ecology_maintainer_doc                            :integer
#  ecology_maintainer_doc_detail                     :string(500)
#  ecology_build                                     :integer
#  ecology_build_detail                              :string(500)
#  ecology_ci                                        :integer
#  ecology_ci_detail                                 :string(500)
#  ecology_test_coverage                             :integer
#  ecology_test_coverage_detail                      :string(500)
#  ecology_code_review                               :integer
#  ecology_code_review_detail                        :string(500)
#  ecology_code_upstream                             :integer
#  ecology_code_upstream_detail                      :string(500)
#  lifecycle_release_note                            :integer
#  lifecycle_release_note_detail                     :string(500)
#  lifecycle_statement                               :integer
#  lifecycle_statement_detail                        :string(500)
#  security_binary_artifact                          :integer
#  security_binary_artifact_detail                   :string(500)
#  security_vulnerability                            :integer
#  security_vulnerability_detail                     :string(500)
#  security_package_sig                              :integer
#  security_package_sig_detail                       :string(500)
#  created_at                                        :datetime         not null
#  updated_at                                        :datetime         not null
#
class TpcSoftwareGraduationReportMetric < ApplicationRecord

  include Common
  extend CompassUtils

  belongs_to :tpc_software_graduation_report
  belongs_to :subject
  belongs_to :user
  has_one :tpc_software_graduation_report_metric_raw
  has_many :tpc_software_comments, as: :tpc_software, dependent: :destroy
  has_many :tpc_software_comment_states, as: :tpc_software, dependent: :destroy

  Status_Progress = 'progress'
  Status_Success = 'success'

  Version_History = 0
  Version_Default = 1

  def self.check_url(url)
    TpcSoftwareReportMetric.check_url(url)
  end

  def self.get_compliance_license(scancode_result)
    license_list = []
    osi_license_list = []
    non_osi_license_list = []

    license_db_data = TpcSoftwareReportMetric.get_license_data

    raw_data = (scancode_result.dig("license_detections") || []).flat_map do |license_detection|
      (license_detection.dig("reference_matches") || []).map do |reference_match|
        keys_to_select = %w[license_expression license_expression_spdx from_file start_line end_line matcher score]
        reference_match.select { |key, _| keys_to_select.include?(key) }
      end
    end

    raw_data.each do |raw|
      (raw.dig("license_expression") || "").split(/ AND | OR /).each do |license_expression|
        license_expression = license_expression.strip.downcase
        license_list << license_expression
        category = license_db_data.dig(license_expression, :category)
        if category
          case category
          when "Permissive"
            osi_license_list << license_expression
          when "Copyleft Limited"
            osi_license_list << license_expression
          else
            osi_license_list << license_expression
          end
        else
          non_osi_license_list << license_expression
        end
      end
    end

    score = 0
    if license_list.length > 0 && non_osi_license_list.length == 0
      score = 10
    end
    detail = {
      osi_license_list: osi_license_list.uniq.take(5),
      non_osi_licenses: non_osi_license_list.uniq.take(5)
    }

    {
      compliance_license: score,
      compliance_license_detail: detail.to_json,
      compliance_license_raw: raw_data.take(30).to_json
    }
  end

  def self.get_compliance_license_compatibility(scancode_result)
    TpcSoftwareReportMetric.get_compliance_license_compatibility(scancode_result)
  end

  def self.get_compliance_dco(project_url)
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(project_url, "repo", GiteeGitEnrich, GithubGitEnrich)
    base = indexer.must(terms: { tag: repo_urls.map { |element| element + ".git" } })
                  .aggregate({ count: { cardinality: { field: "uuid" } }})
                  .per(0)

    commit_count = base.execute.aggregations.dig('count', 'value')
    commit_dco_count = base.must(wildcard: { message: { value: "*Signed-off-by*" } })
                           .execute.aggregations.dig('count', 'value')
    score = 0
    if commit_count > 0 && commit_count == commit_dco_count
      score = 10
    end
    detail = {
      commit_count: commit_count,
      commit_dco_count: commit_dco_count,
    }
    { compliance_dco: score, compliance_dco_detail: detail.to_json }
  end

  def self.get_ecology_issue_management(project_url)
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(project_url, "repo", GiteeIssueEnrich, GithubIssueEnrich)

    base = indexer.must(terms: { tag: repo_urls })
                  .must(match_phrase: { item_type: "issue" })
                  .per(0)
    issue_count = base.aggregate({ count: { cardinality: { field: "uuid" } }})
                      .execute
                      .aggregations
                      .dig('count', 'value')
    issue_type_list = base.aggregate({ issue_type: { terms: { field: "issue_type" } } })
                          .execute
                          .aggregations
                          .dig('issue_type', 'buckets')
    score = 0
    if issue_count > 0
      score = 6
      if issue_type_list.length > 0
        score = 10
      end
    end

    detail = {
      issue_count: issue_count,
      issue_type_list: issue_type_list,
    }
    { ecology_issue_management: score, ecology_issue_management_detail: detail.to_json }
  end

  def self.get_ecology_issue_response_ratio(project_url)
    begin_date = 6.months.ago
    end_date = Time.current
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(project_url, "repo", GiteeIssueEnrich, GithubIssueEnrich)
    base = indexer.must(terms: { tag: repo_urls})
                  .must(match_phrase: { item_type: "issue" })
                  .aggregate({ count: { cardinality: { field: "uuid" } }})
                  .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                  .per(0)
    issue_count = base.execute
                      .aggregations
                      .dig('count', 'value')
    issue_response_count = base.range(:num_of_comments_without_bot, gt: 0)
                          .execute
                          .aggregations
                          .dig('count', 'value')
    issue_response_ratio = 0
    score = 6
    if issue_count > 0
      issue_response_ratio = issue_response_count / issue_count
      if issue_response_ratio >= 0.8
        score = 10
      end
    end

    detail = {
      issue_count: issue_count,
      issue_response_count: issue_response_count,
      issue_response_ratio: issue_response_ratio,
    }
    { ecology_issue_response_ratio: score, ecology_issue_response_ratio_detail: detail.to_json }
  end

  def self.get_ecology_issue_response_time(project_url)
    begin_date = 6.months.ago
    end_date = Time.current
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(project_url, "repo", GiteeIssueEnrich, GithubIssueEnrich)
    base = indexer.must(terms: { tag: repo_urls})
                  .must(match_phrase: { item_type: "issue" })
                  .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                  .range(:num_of_comments_without_bot, gt: 0)
                  .per(0)
    issue_response_count = base.aggregate({ count: { cardinality: { field: "uuid" } }})
                               .execute
                               .aggregations
                               .dig('count', 'value')
    issue_response_time = base.aggregate({ avg_count: { avg: { field: "time_to_first_attention_without_bot" } }})
                               .execute
                               .aggregations
                               .dig('count', 'value')

    score = 0
    if issue_response_count > 0
      score = case issue_response_time
              when 0..14
                10
              when 15..30
                8
              else
                6
              end
    end

    detail = {
      issue_response_count: issue_response_count,
      issue_response_time: issue_response_time,
    }
    { ecology_issue_response_time: score, ecology_issue_response_time_detail: detail.to_json }
  end

  def self.get_ecology_test_coverage(sonar_scanner_result)
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
      ecology_test_coverage: score,
      ecology_test_coverage_detail: detail.to_json,
      ecology_test_coverage_raw: sonar_scanner_result.to_json
    }
  end

  def self.get_ecology_code_review(project_url)
    indexer, repo_urls =
      select_idx_repos_by_lablel_and_level(project_url, "repo", GiteePullEnrich, GithubPullEnrich)
    base = indexer.must(terms: { tag: repo_urls})
                  .must(match_phrase: { item_type: "pull request" })
                  .must(match_phrase: { merged: true })
                  .aggregate({ count: { cardinality: { field: "uuid" } }})
                  .per(0)
    pull_count = base.execute
                     .aggregations
                     .dig('count', 'value')
    pull_review_count = base.range(:num_review_comments_without_bot, gt: 0)
                            .execute
                            .aggregations
                            .dig('count', 'value')
    pull_review_ratio = 0
    score = 0
    if pull_count > 0
      pull_review_ratio = pull_review_count.to_f / pull_count
      score = case pull_review_ratio
              when 0.8..1.0
                10
              when 0.6...0.8
                6
              else
                0
              end
    end

    detail = {
      pull_count: pull_count,
      pull_review_count: pull_review_count,
      pull_review_ratio: pull_review_ratio,
    }
    { ecology_code_review: score, ecology_code_review_detail: detail.to_json }
  end

  def self.get_security_binary_artifact(binary_checker_result)
    TpcSoftwareReportMetric.get_security_binary_artifact(binary_checker_result)
  end

  def self.get_security_vulnerability(osv_scanner_result)
    TpcSoftwareReportMetric.get_security_vulnerability(osv_scanner_result)
  end

  def self.get_security_package_sig(signature_checker_result)
    signature_file_list = signature_checker_result.dig("signature_file_list") || []

    score = 6
    if signature_file_list.length > 0
      score = 10
    end
    {
      security_package_sig: score,
      security_package_sig_detail: signature_file_list.take(5).to_json,
      security_package_sig_raw: signature_file_list.take(30).to_json
    }
  end

end
