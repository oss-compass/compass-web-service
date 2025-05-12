# frozen_string_literal: true

module Openapi
  module V2
    class ContributorRepo < Grape::API

      version 'v2', using: :path
      prefix :api
      format :json

      before { require_login! }
      MAX_PER = 10000
      # github_event_contributor_repo_enrich
      helpers Openapi::SharedParams::Search
      resource :contributor_repo do

        desc 'Query the contribution association between contributors and repositories', { tags: ['L2 Portrait/Metric data'] }
        params {
          requires :contributor, type: String, desc: 'github or gitee platform user account name', documentation: { param_type: 'body',example: 'lishengbao' }
          # requires :contributor_type, type: String, desc: 'github or gitee platform type', documentation: { param_type: 'body',example: 'github' }
          requires :begin_date, type: DateTime, desc: 'begin date / 开始日期', documentation: { param_type: 'body' }
          requires :end_date, type: DateTime, desc: 'end date / 结束日期', documentation: { param_type: 'body' }
        }
        post :collaborative do
          indexer = GithubEventContributorRepoEnrich
          resp = indexer.list(params[:contributor], params[:begin_date], params[:end_date], page: 1, per: MAX_PER)
          hits = resp&.[]('hits')&.[]('hits') || []

          repo_contribution_list = hits.each_with_object({}) do |hit, result|
            data = hit['_source']
            repo = data['repo']

            result[repo] ||= {
              'repo' => repo,
              'push_contribution' => 0,
              'pull_request_contribution' => 0,
              'pull_request_comment_contribution' => 0,
              'issue_contribution' => 0,
              'issue_comment_contribution' => 0,
              'total_contribution' => 0
            }

            contribution_map = {
              'push_contribution' => 'push_contribution',
              'pull_request_contribution' => 'pull_request_opened_contribution',
              'pull_request_comment_contribution' => 'pull_request_review_commented_contribution',
              'issue_contribution' => 'issues_opened_contribution',
              'issue_comment_contribution' => 'issue_comment_created_contribution'
            }

            contribution_map.each do |target_field, source_field|
              result[repo][target_field] += data[source_field].to_i
            end

            result[repo]['total_contribution'] =
              result[repo]['push_contribution'] +
              result[repo]['pull_request_contribution'] +
              result[repo]['pull_request_comment_contribution'] +
              result[repo]['issue_contribution'] +
              result[repo]['issue_comment_contribution']
          end.values
             .sort_by { |item| -item['total_contribution'] }
             .select { |item| item['total_contribution'] > 0 }

          repo_contribution_list
        end

      end
    end
  end
end
