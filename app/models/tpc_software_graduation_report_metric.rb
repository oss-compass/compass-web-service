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
#  compliance_snippet_reference                      :integer
#  compliance_snippet_reference_detail               :string(500)
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
  Status_Again_Progress = 'again_progress'
  Status_Success = 'success'

  Version_History = 0
  Version_Default = 1

  def report_score
    compliance_metric_score = [compliance_license, compliance_dco, compliance_license_compatibility,
                               compliance_copyright_statement, compliance_copyright_statement_anti_tamper,
                               compliance_snippet_reference]
    compliance_metric_score_filter = compliance_metric_score.compact.reject { |element| element == -1 }
    compliance_score = compliance_metric_score_filter.sum(0) * 10 / compliance_metric_score_filter.size

    ecology_metric_score = [ecology_readme, ecology_build_doc, ecology_interface_doc, ecology_issue_management,
                            ecology_issue_response_ratio, ecology_issue_response_time, ecology_maintainer_doc,
                            ecology_build, ecology_ci, get_ecology_test_coverage, ecology_code_review, ecology_code_upstream]
    ecology_metric_score_filter = ecology_metric_score.compact.reject { |element| element == -1 }
    ecology_score = ecology_metric_score_filter.sum(0) * 10 / ecology_metric_score_filter.size

    lifecycle_metric_score = [lifecycle_release_note, lifecycle_statement]
    lifecycle_metric_score_filter = lifecycle_metric_score.compact.reject { |element| element == -1 }
    lifecycle_score = lifecycle_metric_score_filter.sum(0) * 10 / lifecycle_metric_score_filter.size

    security_metric_score = [security_binary_artifact, security_vulnerability, security_package_sig]
    security_metric_score_filter = security_metric_score.compact.reject { |element| element == -1 }
    security_score = security_metric_score_filter.sum(0) * 10 / security_metric_score_filter.size

    total_score = [compliance_score, ecology_score, lifecycle_score, security_score]
    total_score = total_score.sum(0) / total_score.size

    [total_score, compliance_score, ecology_score, lifecycle_score, security_score]
  end

  def self.check_url(url)
    TpcSoftwareReportMetric.check_url(url)
  end

  def self.get_compliance_license(scancode_result, readme_opensource_checker_result)
    license_list = []
    osi_license_list = []
    non_osi_license_list = []
    readme_opensource = readme_opensource_checker_result.dig("readme-opensource-checker") || false

    license_db_data = TpcSoftwareReportMetric.get_license_data

    raw_data = (scancode_result.dig("files") || []).map do |file|
      keys_to_select = %w[path type detected_license_expression detected_license_expression_spdx]
      file_type = file.dig("type") || ""
      from_file_split = (file.dig("path") || "").downcase.split("/")
      if file_type == "file" && file.dig("detected_license_expression") &&
        (from_file_split.length == 2 || from_file_split.length >= 2 && from_file_split[1] == "license")
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

    score = 0
    if license_list.length > 0 && non_osi_license_list.length == 0 && readme_opensource
      score = 10
    end
    detail = {
      readme_opensource: readme_opensource,
      osi_license_list: osi_license_list.uniq.take(1),
      non_osi_licenses: non_osi_license_list.uniq.take(1)
    }

    {
      compliance_license: score,
      compliance_license_detail: detail.to_json,
      compliance_license_raw: raw_data.take(10).to_json
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
    issue_type_buckets = base.aggregate({ issue_type: { terms: { field: "issue_type" } } })
                          .execute
                          .aggregations
                          .dig('issue_type', 'buckets')
    issue_type_list = issue_type_buckets.map do |bucket|
      bucket.dig("key")
    end


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
      issue_response_ratio = (issue_response_count.to_f / issue_count).round(2)
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
    issue_response_time = base.aggregate({ count: { avg: { field: "time_to_first_attention_without_bot" } }})
                               .execute
                               .aggregations
                               .dig('count', 'value')
    if issue_response_time.present?
      issue_response_time = issue_response_time.round(2)
    end
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
                  .per(0)
    pull_count = base.aggregate({ count: { cardinality: { field: "uuid" } }})
                     .execute
                     .aggregations
                     .dig('count', 'value')
    if project_url.include?("gitee.com")
      pull_id_list = []
      pull_id_buckets = base.aggregate({ pull_id_list: { terms: { field: "id_in_repo", size: 10000 } }})
                              .range(:num_review_comments_without_bot, gt: 0)
                              .execute
                              .aggregations
                              .dig('pull_id_list', 'buckets')
      pull_id_buckets.each {|pull_id_bucket| pull_id_list << pull_id_bucket.dig("key")}
      event_pull_id_buckets = GiteeEventEnrich.aggregate({ pull_id_list: { terms: { field: "pull_id_in_repo", size: 10000 } } })
                                              .must(terms: { tag: repo_urls })
                                              .must(match_phrase: { item_type: "pull request" })
                                              .must(match_phrase: { pull_state: "merged" })
                                              .must(match_phrase: { action_type: "check_pass" })
                                              .per(0)
                                              .execute
                                              .aggregations
                                              .dig('pull_id_list', 'buckets')
      event_pull_id_buckets.each { |pull_id_bucket| pull_id_list << pull_id_bucket.dig("key") }
      pull_review_count = pull_id_list.uniq.length
      if pull_review_count > pull_count
        pull_review_count = pull_count
      end
    else
      pull_review_count = base.aggregate({ count: { cardinality: { field: "uuid" } }})
                              .range(:num_review_comments_without_bot, gt: 0)
                              .execute
                              .aggregations
                              .dig('count', 'value')
    end

    pull_review_ratio = 0
    score = 0
    if pull_count > 0
      pull_review_ratio = (pull_review_count.to_f / pull_count).round(2)
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

  def self.get_security_package_sig(release_checker_result)
    signature_file_list = release_checker_result.dig("signature_files") || []

    if release_checker_result.include?("error")
      score = -1
    else
      score = 6
      if signature_file_list.length > 0
        score = 10
      end
    end
    {
      security_package_sig: score,
      security_package_sig_detail: signature_file_list.take(2).to_json,
      security_package_sig_raw: signature_file_list.take(30).to_json
    }
  end

  def self.get_lifecycle_release_note(release_checker_result)
    release_notes = release_checker_result.dig("release_notes") || []

    if release_checker_result.include?("error")
      score = -1
    else
      score = 0
      if release_notes.length > 0
        score = 10
      end
    end
    {
      lifecycle_release_note: score,
      lifecycle_release_note_detail: release_notes.take(1).to_json,
      lifecycle_release_note_raw: release_notes.take(30).to_json
    }
  end

  def self.get_compliance_copyright_statement(scancode_result)
    source_code_files = %w[.c .cpp .java .py .rb .js .html .css .php .swift .kt]

    include_copyrights = []
    not_included_copyrights = []
    raw_list = []
    (scancode_result.dig("files") || []).each do |file|
      file_path = file.dig("path")
      file_path_split = file_path.split("/")
      next if file_path_split.length > 2 && file_path_split[1] == "hvigor"
      if file.dig("type") == "file" && source_code_files.any? { |ext| file_path.end_with?(ext) }
        if (file.dig("copyrights") || []).length > 0
          include_copyrights << file_path
        else
          not_included_copyrights << file_path
        end
      end

      if file.dig("type") == "file"
        raw_item = {
          "path": file_path,
          "copyrights": (file.dig("copyrights") || []).map do |copyright|
            copyright.dig("copyright")
          end
        }
        raw_list << raw_item
      end
    end

    score = 0
    if include_copyrights.length > 0 && not_included_copyrights.length == 0
      score = 10
    end

    detail = {
      "include_copyrights": include_copyrights.uniq.take(1),
      "not_included_copyrights": not_included_copyrights.uniq.take(1),
    }

    {
      compliance_copyright_statement: score,
      compliance_copyright_statement_detail: detail.to_json,
      compliance_copyright_statement_raw: raw_list.take(5).to_json
    }
  end

  def self.get_ecology_readme(readme_checker_result)
    readme_files = %w[readme readme.]

    readme_file_list = readme_checker_result.dig("readme_file") || []

    score = 0
    readme_file_list.each do |readme_file|
      readme_file_split = readme_file.split("/")
      if readme_file_split.length == 2 && readme_files.any? { |item| readme_file_split[1].downcase.include?(item) }
        score = 10
        break
      end
    end

    {
      ecology_readme: score,
      ecology_readme_detail: nil,
      ecology_readme_raw: readme_file_list.take(50).to_json
    }
  end

  def self.get_ecology_maintainer_doc(maintainers_checker_result)
    raw_data = maintainers_checker_result.dig("maintainers_file") || []
    score = 0
    if raw_data.length > 0
      score = 10
    end

    {
      ecology_maintainer_doc: score,
      ecology_maintainer_doc_detail: nil,
      ecology_maintainer_doc_raw: raw_data.take(30).to_json
    }
  end


  def self.get_ecology_build_doc(build_doc_checker_result)
    raw_data = build_doc_checker_result.dig("build-doc-checker") || []
    score = 0
    if raw_data.length > 0
      score = 10
    end

    {
      ecology_build_doc: score,
      ecology_build_doc_detail: nil,
      ecology_build_doc_raw: raw_data.take(30).to_json
    }
  end


  def self.get_ecology_interface_doc(api_doc_checker_result)
    raw_data = api_doc_checker_result.dig("api-doc-checker") || []
    score = 0
    if raw_data.length > 0
      score = 10
    end

    {
      ecology_interface_doc: score,
      ecology_interface_doc_detail: nil,
      ecology_interface_doc_raw: raw_data.take(30).to_json
    }
  end

  def get_ecology_test_coverage
    quality_detail = ecology_test_coverage_detail.present? ? JSON.parse(ecology_test_coverage_detail) : {}
    if quality_detail.dig("duplication_ratio").nil? || quality_detail.dig("coverage_ratio").nil?
      -1
    else
      ecology_test_coverage
    end
  end

end
