# frozen_string_literal: true
module ContributorRepoEnrich
  extend ActiveSupport::Concern

  class_methods do
    def list(contributor, begin_date, end_date, page: 1, per: 1)
      self.must(match_phrase: { 'contributor.keyword': contributor })
          .range('created_at', gte: begin_date, lte: end_date)
          .page(page)
          .per(per)
          .execute
          .raw_response
    end

    def sum_contribution(contributor, begin_date, end_date, field = "push_contribution")

      resp_count = self.aggregate(count: { sum: { field: field } })
                       .must(match_phrase: { 'contributor.keyword': contributor })
                       .range('created_at', gte: begin_date, lte: end_date)
                       .per(0)
                       .execute
                       .raw_response
      resp_count&.[]('aggregations')&.[]('count')&.[]('value') || 0
    end

    def push_contribution_rank(contributor, begin_date, end_date)

      push_contribution_top_rank_definition = {
        '95%': [2 * 0, 2 * 6],
        '90%': [2 * 6, 2 * 12],
        '85%': [2 * 12, 2 * 18],
        '80%': [2 * 18, 2 * 24],
        '75%': [2 * 24, 2 * 30],
        '70%': [2 * 30, 2 * 36],
        '65%': [2 * 36, 2 * 42],
        '60%': [2 * 42, 2 * 48],
        '55%': [2 * 48, 2 * 54],
        '50%': [2 * 54, 2 * 60],
        '45%': [2 * 60, 2 * 66],
        '40%': [2 * 66, 2 * 72],
        '35%': [2 * 72, 2 * 78],
        '30%': [2 * 78, 2 * 92],
        '25%': [2 * 92, 2 * 110],
        '20%': [2 * 110, 2 * 140],
        '15%': [2 * 140, 2 * 188],
        '10%': [2 * 188, 2 * 296],
        '5%': [2 * 296, 2 * 99_999_999]
      }
      contribution = sum_contribution(contributor, begin_date, end_date, field = "push_contribution")
      found_percentage = push_contribution_top_rank_definition.find do |percentage, range|
        min, max = range
        min <= contribution && contribution < max
      end
      rank = found_percentage[0] if found_percentage
      [rank, contribution]
    end

    def issue_contribution_rank(contributor, begin_date, end_date)

      issue_contribution_top_rank_definition = {
        '95%': [0, 3],
        '90%': [3, 6],
        '85%': [6, 9],
        '80%': [9, 12],
        '75%': [12, 15],
        '70%': [15, 18],
        '65%': [18, 21],
        '60%': [21, 24],
        '55%': [24, 27],
        '50%': [27, 30],
        '45%': [30, 33],
        '40%': [33, 36],
        '35%': [36, 39],
        '30%': [39, 42],
        '25%': [42, 45],
        '20%': [45, 56],
        '15%': [56, 72],
        '10%': [72, 102],
        '5%': [102, 99_999_999]
      }
      contribution = sum_contribution(contributor, begin_date, end_date, field = "issues_opened_contribution")
      found_percentage = issue_contribution_top_rank_definition.find do |percentage, range|
        min, max = range
        min <= contribution && contribution < max
      end
      rank = found_percentage[0] if found_percentage
      [rank, contribution]

    end

    def pull_contribution_rank(contributor, begin_date, end_date)

      pull_contribution_top_rank_definition = {
        '95%': [2 * 0, 2 * 3],
        '90%': [2 * 3, 2 * 6],
        '85%': [2 * 6, 2 * 9],
        '80%': [2 * 9, 2 * 12],
        '75%': [2 * 12, 2 * 15],
        '70%': [2 * 15, 2 * 18],
        '65%': [2 * 18, 2 * 21],
        '60%': [2 * 21, 2 * 24],
        '55%': [2 * 24, 2 * 27],
        '50%': [2 * 27, 2 * 30],
        '45%': [2 * 30, 2 * 33],
        '40%': [2 * 33, 2 * 36],
        '35%': [2 * 36, 2 * 39],
        '30%': [2 * 39, 2 * 42],
        '25%': [2 * 42, 2 * 45],
        '20%': [2 * 45, 2 * 56],
        '15%': [2 * 56, 2 * 72],
        '10%': [2 * 72, 2 * 102],
        '5%': [2 * 102, 2 * 99_999_999]
      }
      contribution = sum_contribution(contributor, begin_date, end_date, field = "pull_request_opened_contribution")
      found_percentage = pull_contribution_top_rank_definition.find do |percentage, range|
        min, max = range
        min <= contribution && contribution < max
      end
      rank = found_percentage[0] if found_percentage
      [rank, contribution]

    end

    def total_rank (count)
      total_rank_definition = {
        '95%' => [0, 21],
        '90' => [21, 42],
        '85%' => [42, 63],
        '80%' => [63, 84],
        '75' => [84, 105],
        '70%' => [105, 126],
        '65%' => [126, 147],
        '60' => [147, 168],
        '55%' => [168, 189],
        '50%' => [189, 210],
        '45' => [210, 231],
        '40%' => [231, 252],
        '35%' => [252, 273],
        '30' => [273, 310],
        '25%' => [310, 355],
        '20%' => [355, 448],
        '15' => [448, 592],
        '10%' => [592, 898],
        '5%' => [898, 99_999_999]
      }

      # 5%  -> s+
      # 5% - 15% ->s
      # 15% -30% -> A+
      # 30% -40 % -> A
      # 40% -> B
      # 找到匹配的排名区间
      level_map = {
        '5%' => 'S+',
        '10%' => 'S',
        '15%' => 'S',
        '20%' => 'A+',
        '25%' => 'A+',
        '30%' => 'A',
        '35%' => 'A',
        '40%' => 'B',
        '45%' => 'B',
        '50%' => 'B',
        '55%' => 'B',
        '60%' => 'B',
        '65%' => 'B',
        '70%' => 'B',
        '75%' => 'B',
        '80%' => 'B',
        '85%' => 'B',
        '90%' => 'B',
        '95%' => 'B'
      }

      total_rank_definition.each do |percentile, range|
        if count >= range[0] && count < range[1]
          return {
            "score" => level_map[percentile],
            "rank" => "#{percentile}"
          }
        end
      end

      {
        "score" => "B",
        "rank" => "99%"
      }

    end

    def repo_list(contributor, begin_date, end_date, page: 1, per: 1)
      resp = self.must(match_phrase: { 'contributor.keyword': contributor })
                 .range('created_at', gte: begin_date, lte: end_date)
                 .page(page)
                 .per(per)
                 .execute
                 .raw_response

      sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []

      fields_to_sum = [
        'push_contribution',
        'pull_request_opened_contribution',
        'pull_request_reopened_contribution',
        'pull_request_closed_contribution',
        'pull_request_merged_contribution',
        'pull_request_review_commented_contribution',
        'issues_opened_contribution',
        'issues_reopened_contribution',
        'issues_closed_contribution',
        'issue_comment_created_contribution'
      ]

      repo_contributions = Hash.new(0)
      sources.each do |item|
        repo = item["repo"]
        next unless repo

        total = fields_to_sum.sum { |field| item[field].to_i }
        repo_contributions[repo] += total
      end

      repo_contributions.map do |repo_url, total|
        {
          repo_url: repo_url,
          repo: repo_url,
          contribution: total
        }
      end.sort_by { |item| -item[:contribution] }
    end


    def get_manage_repos(sources)
      sources.select do |item|
        item['pull_request_merged_contribution'].to_i > 0 ||
          item['push_contribution'].to_i > 0 ||
          item['pull_request_review_approved_contribution'].to_i > 0
      end.map { |item| item['repo'] }.compact.uniq
    end

    def get_personal_manage_repo(sources, contributor)
      sources.select do |item|
        repo = item['repo']
        (item['pull_request_merged_contribution'].to_i > 0 ||
          item['push_contribution'].to_i > 0 ||
          item['pull_request_review_approved_contribution'].to_i > 0) &&
          repo.include?(contributor)
      end.map { |item| item['repo'] }.compact.uniq
    end

    def get_org_manage_repo(sources, contributor)
      sources.select do |item|
        repo = item['repo']
        (item['pull_request_merged_contribution'].to_i > 0 ||
          item['push_contribution'].to_i > 0 ||
          item['pull_request_review_approved_contribution'].to_i > 0) &&
          !repo.include?(contributor)
      end.map { |item| item['repo'] }.compact.uniq
    end

  end

end
