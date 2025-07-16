class DeveloperChartController < ApplicationController
  def show
    developer = params[:developer]
    params[:begin_date], params[:end_date] = extract_range

    if developer.present?
      option = get_contribution_overview(params[:begin_date], params[:end_date], developer)
      params[:option] = option

      svg = DeveloperChartRenderServer.new(params).render!
      return render xml: svg, layout: false, content_type: 'image/svg+xml'

    end
    render template: 'chart/empty', layout: false, content_type: 'image/svg+xml'
  rescue => ex
    Rails.logger.error("Failed to render svg chart: #{ex.message}")
    render template: 'chart/empty', layout: false, content_type: 'image/svg+xml'
  end

  def get_contribution_overview(begin_date, end_date, contributor)
    max_pre = 10000
    enrich_indexer = GithubEventContributorRepoEnrich
    resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: max_pre)
    sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []

    # 贡献仓库数量
    contributed_to_count = sources.pluck('repo').uniq.size

    # commit 数
    commit_count = sources.sum { |item| item['push_contribution'].to_i }

    # pr 数
    pr_fields = [
      'pull_request_opened_contribution',
      'pull_request_reopened_contribution',
      'pull_request_closed_contribution',
      'pull_request_merged_contribution'
    ]
    pr_count = sources.sum do |item|
      pr_fields.sum { |field| item[field].to_i }
    end

    # issue 数
    issue_fields = [
      'issues_opened_contribution',
      'issues_reopened_contribution',
      'issue_comment_created_contribution',
      'issues_closed_contribution',
    ]
    issue_count = sources.sum do |item|
      issue_fields.sum { |field| item[field].to_i }
    end

    # code review 计算
    code_review_fields = [
      'pull_request_review_approved_contribution',
      'pull_request_review_commented_contribution',
      'pull_request_review_changes_requested_contribution'
    ]
    code_review_count = sources.sum do |item|
      code_review_fields.sum { |field| item[field].to_i }
    end
    level = enrich_indexer.total_rank(commit_count + pr_count + issue_count)

    {
      commit_count: commit_count,
      pr_count: pr_count,
      issue_count: issue_count,
      code_review_count: code_review_count,
      contributed_to_count: contributed_to_count,
      level: level
    }
  end

  def extract_range
    today = Date.today.end_of_day
    case params[:range]
    when '3M'
      [today - 3.months, today]
    when '6M'
      [today - 6.months, today]
    when '1Y'
      [today - 1.year, today]
    when '2Y'
      [today - 2.years, today]
    when '3Y'
      [today - 3.years, today]
    when '5Y'
      [today - 5.years, today]
    when 'Since 2000'
      [DateTime.new(2000), today]
    else
      [params[:begin_date], params[:end_date]]
    end
  end
end
