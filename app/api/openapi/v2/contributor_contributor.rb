# frozen_string_literal: true

module Openapi
  module V2
    class ContributorContributor < Grape::API

      version 'v2', using: :path
      prefix :api
      format :json

      before { require_login! }
      MAX_PER = 10000
      # github_event_contributor_contributor_enrich
      helpers Openapi::SharedParams::Search
      resource :contributor_contributor do

        desc 'Query the contribution association between contributors and contributors', { tags: ['L2 Portrait/Metric data'] }
        params {
          requires :contributor, type: String, desc: 'github or gitee platform user account name', documentation: { param_type: 'body',example: 'lishengbao' }
          # requires :contributor_type, type: String, desc: 'github or gitee platform type', documentation: { param_type: 'body',example: 'github' }
          requires :begin_date, type: DateTime, desc: 'begin date / 开始日期', documentation: { param_type: 'body' }
          requires :end_date, type: DateTime, desc: 'end date / 结束日期', documentation: { param_type: 'body' }
        }
        post :collaborative do
          indexer = GithubEventContributorContributorEnrich
          resp = indexer.list(params[:contributor], params[:begin_date], params[:end_date], page: 1, per: MAX_PER)
          hits = resp&.[]('hits')&.[]('hits') || []

          contributor_contribution_list = hits.each_with_object({}) do |hit, result|
            data = hit['_source']
            to_contributor = data['to_contributor']

            result[to_contributor] ||= {
              'to_contributor' => to_contributor,
              'pull_request_contribution' => 0,
              'pull_request_comment_contribution' => 0,
              'issue_contribution' => 0,
              'issue_comment_contribution' => 0,
              'total_contribution' => 0
            }

            contribution_maps = {
              direct: {
                'pull_request_contribution' => 'pull_request_opened_contribution',
                'pull_request_comment_contribution' => 'pull_request_review_comment_created_contribution',
                'issue_contribution' => 'issues_opened_contribution',
                'issue_comment_contribution' => 'issue_comment_created_contribution'
              },
              indirect: {
                'pull_request_comment_contribution' => 'pull_request_review_comment_created_indirect_contribution',
                'issue_comment_contribution' => 'issue_comment_created_indirect_contribution'
              }
            }
            contribution_maps.each do |contribution_type, map|
              map.each do |target_field, source_field|
                result[to_contributor][target_field] = result[to_contributor].fetch(target_field, 0) + data.fetch(source_field, 0)
              end
            end

            result[to_contributor]['total_contribution'] =
              result[to_contributor]['pull_request_contribution'] +
              result[to_contributor]['pull_request_comment_contribution'] +
              result[to_contributor]['issue_contribution'] +
              result[to_contributor]['issue_comment_contribution']
          end.values
             .sort_by { |item| -item['total_contribution'] }
             .select { |item| item['total_contribution'] > 0 }

          contributor_contribution_list
        end

      end
    end
  end
end
