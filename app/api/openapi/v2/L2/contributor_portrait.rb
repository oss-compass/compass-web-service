# frozen_string_literal: true

module Openapi
  module V2
    module L2
      class ContributorPortrait < Grape::API

      version 'v2', using: :path
      prefix :api
      format :json

      helpers Openapi::SharedParams::CustomMetricSearch
      helpers Openapi::SharedParams::AuthHelpers
      helpers Openapi::SharedParams::ErrorHelpers

      rescue_from :all do |e|
        case e
        when Grape::Exceptions::ValidationErrors
          handle_validation_error(e)
        when SearchFlip::ResponseError
          handle_open_search_error(e)
        else
          handle_generic_error(e)
        end
      end

      # before { require_token! }
      MAX_PER = 10000
      resource :contributor_portrait do


        desc '开发者贡献排名',
             detail: '开发者的代码贡献, PR贡献, Issue贡献在全球年度排名',
             tags: ['Metrics Data', 'Contributor Portrait'],
             success: {
               code: 201, model: Openapi::Entities::ContributorPortraitContributionRankResponse
             }
        params {
          use :contributor_portrait_search
        }
        post :contribution_rank do

          begin_date = Date.new(params[:begin_date].year, 1, 1)
          end_date = Date.new(params[:begin_date].year + 1, 1, 1)

          indexer = GithubEventContributorRepoEnrich
          push_rank, push_contribution = indexer.push_contribution_rank(params[:contributor], begin_date, end_date)
          issue_rank, issue_contribution = indexer.issue_contribution_rank(params[:contributor], begin_date, end_date)
          pull_rank, pull_contribution = indexer.pull_contribution_rank(params[:contributor], begin_date, end_date)
          
          {
            push_contribution: push_contribution,
            pull_request_contribution: pull_contribution,
            issue_contribution: issue_contribution,
            push_contribution_rank: push_rank,
            pull_request_contribution_rank: pull_rank,
            issue_contribution_rank: issue_rank
          }

        end

        desc '开发者对仓库贡献',
             detail: '开发者对仓库的代码贡献, Issue贡献, Issue评论, PR贡献以及PR审核贡献',
             tags: ['Metrics Data', 'Contributor Portrait'],
             success: {
               code: 201, model: Openapi::Entities::ContributorPortraitRepoCollaborationResponse
             }
        params {
          use :contributor_portrait_search
        }
        post :repo_collaboration do
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


        desc '开发者协作',
             detail: '通过Issue、PR及其对应的评论信息，与其他开发者建立协作关系',
             tags: ['Metrics Data', 'Contributor Portrait'],
             success: {
               code: 201, model: Openapi::Entities::ContributorPortraitContributorCollaborationResponse
             }
        params {
          use :contributor_portrait_search
        }
        post :contributor_collaboration do
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
end
