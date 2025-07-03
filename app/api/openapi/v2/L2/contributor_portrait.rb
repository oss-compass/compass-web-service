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

        helpers do
          def aggregate_monthly_values(sources, end_date, field_names)
            monthly_counts = Hash.new(0)

            sources.each do |source|
              event_date_str = source['created_at']
              next unless event_date_str

              event_date = Date.parse(event_date_str) rescue nil
              next unless event_date

              month_key = event_date.strftime('%Y-%m')

              field_names.each do |field|
                monthly_counts[month_key] += source[field].to_i if source[field]
              end
            end

            monthly_counts.map do |month, count|
              date = if month == end_date.strftime('%Y-%m')
                       end_date.strftime('%Y-%m-%d')
                     else
                       Date.parse("#{month}-01").next_month.prev_day.strftime('%Y-%m-%d')
                     end

              { date: date, value: count }
            end.sort_by { |item| item[:date] }
          end
        end

        # before { require_token! }
        MAX_PER = 10000
        resource :contributor_portrait do


          desc 'Developer Contribution Ranking / 开发者贡献排名',
               detail: 'Global annual ranking of developer code contributions, PR contributions, and Issue contributions / 开发者的代码贡献, PR贡献, Issue贡献在全球年度排名',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
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

          desc 'Developer Overview / 开发者概览',
               detail: 'Overview of developer contributions and information / 开发者概览',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201, model: Openapi::Entities::ContributorOverviewResponse
               }
          params {
            use :contributor_portrait_search
          }
          post :contributor_overview do
            begin_date = params[:begin_date]
            end_date = params[:end_date]
            contributor = params[:contributor]

            enrich_indexer = GithubEventContributorRepoEnrich
            event_indexer = GithubEventContributor
            event_repo_indexer = GithubEventRepositoryEnrich

            event_data = event_indexer.query_name(contributor)
            resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
            sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []
            topic_contributions = Hash.new(0)
            sources.each do |item|
              contrib = item["total_contribution"].to_i
              (item["repo_topic_list"] || []).each do |topic|
                next if (item["pull_request_additions"].to_i > 0) || (item["pull_request_deletions"].to_i > 0)
                topic_contributions[topic] += contrib
              end
            end

            # 当有pull_request_merged_contribution,pull_request_review_approved_contribution时取出repo作为管理repo
            manage_repos = sources.select do |item|
              (item['pull_request_merged_contribution'].to_i > 0) || (item['push_contribution'].to_i > 0) ||
                (item['pull_request_review_approved_contribution'].to_i > 0)
            end.map { |item| item['repo'] }.compact.uniq

            # 累加每种语言的贡献值
            language_contributions = Hash.new(0)
            sources.each do |item|
              lang = item["repo_main_language"]
              contrib = item["total_contribution"].to_i
              language_contributions[lang] += contrib if lang
            end
            # 找出 total_contribution 累加值最大的语言
            main_language = language_contributions.max_by { |_, v| v }&.first
            core_repo = event_repo_indexer.query_core_project(contributor, begin_date, end_date, page: 1, per: MAX_PER)

            # 提取非空的国家和城市作为备选值
            fallback_country = sources.map { |s| s['contributor_country'] }.compact.find { |c| !c.to_s.strip.empty? }
            # 将 中文 country 转换为英文
            country_raw = Openapi::SharedParams::CityMap.to_en(fallback_country)

            fallback_city = sources.map { |s| s['contributor_city'] }.compact.find { |c| !c.to_s.strip.empty? }
            city_raw = sources.map { |s| s['contributor_city_raw'] }.compact.find { |c| !c.to_s.strip.empty? }
            fallback_org = sources.map { |s| s['contributor_org'] }.compact.find { |c| !c.to_s.strip.empty? }


            all_repos_contribution = enrich_indexer.repo_list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
            # 构建角色映射
            org =  event_data['company'] || fallback_org
            repo_roles = all_repos_contribution.map do |repos|
              repo = repos[:repo_url]
              contribution = repos[:contribution]
              roles = []
              if manage_repos.include?(repo)
                roles << (org.present? ? 'organization_manager' : 'individual_manager')
              end

              unless manage_repos.include?(repo)
                roles << (org.present? ? 'organization_participant' : 'individual_participant')
              end

              roles << (core_repo.include?(repo) ? 'core' : 'guest')
              {
                repo: repo,
                roles: roles,
                contribution: contribution
              }
            end

            topic_contributions_array = topic_contributions.map do |topic, contrib|
              { name: topic, value: contrib }
            end
            {
              avatar_url: event_data['avatar_url'],
              html_url: event_data['html_url'],
              country: event_data['country'] || fallback_country,
              country_raw: country_raw,
              city: event_data['city'] || fallback_city,
              city_row: city_raw,
              company: event_data['company'] || fallback_org,
              main_language: main_language,
              repo_roles: repo_roles,
              topics: topic_contributions_array
            }

          end

          desc 'Developer / 开发者贡献概览',
               detail: '开发者贡献概览',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201, model: Openapi::Entities::ContributorOverviewResponse
               }
          params {
            use :contributor_portrait_search
          }
          post :contribution_overview do
            begin_date = params[:begin_date]
            end_date = params[:end_date]
            contributor = params[:contributor]
            enrich_indexer = GithubEventContributorRepoEnrich
            resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
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
              'pull_request_merged_contribution',
            # 'pull_request_additions',
            # 'pull_request_deletions',
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
            level = enrich_indexer.total_rank(commit_count+pr_count+issue_count)

            {
              commit_count: commit_count,
              pr_count: pr_count,
              issue_count: issue_count,
              code_review_count: code_review_count,
              contributed_to_count: contributed_to_count,
              level:level
            }
          end

          desc 'An overview of developer programming languages / 开发者编程语言概览',
               detail: 'An overview of developer programming languages / 开发者编程语言概览',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201, model: Openapi::Entities::ContributorLanguageResponse
               },
               is_array: true
          params {
            use :contributor_portrait_search
          }
          post :contributor_language do
            begin_date = params[:begin_date]
            end_date = params[:end_date]
            contributor = params[:contributor]

            enrich_indexer = GithubEventContributorRepoEnrich

            resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
            sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []

            # 累加每种语言的贡献值
            language_contributions = Hash.new(0)
            sources.each do |item|
              lang = item["repo_main_language"]
              contrib = item["total_contribution"].to_i
              language_contributions[lang] += contrib if lang
            end
            total = language_contributions.values.sum

            # 构造语言占比
            languages = language_contributions.map do |lang, count|
              {
                language: lang,
                contribution: count,
                ratio: total.zero? ? 0.0 : ((count.to_f / total) * 100).round(2)
              }
            end.sort_by { |item| -item[:ratio] }

          end

          desc 'Developer Repository Contribution Ranking / 开发者贡献仓库排名',
               detail: 'Ranking of repositories by developer contributions / 开发者贡献仓库排名',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201, model: Openapi::Entities::ContributorReposResponse,
               },
               is_array: true
          params {
            use :contributor_portrait_search
          }
          post :contributor_repos do
            begin_date = params[:begin_date]
            end_date = params[:end_date]
            contributor = params[:contributor]

            enrich_indexer = GithubEventContributorRepoEnrich
            event_repo_indexer = GithubEventRepositoryEnrich
            event_indexer = GithubEventContributor
            resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
            sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []

            manage_repo = enrich_indexer.get_manage_repos(sources)

            core_repo = event_repo_indexer.query_core_project(contributor, begin_date, end_date, page: 1, per: MAX_PER)


            repo_contributions = enrich_indexer.repo_list(contributor, begin_date, end_date, page: 1, per: MAX_PER).first(5)

            fallback_org = sources.map { |s| s['contributor_org'] }.compact.find { |c| !c.to_s.strip.empty? }
            event_data = event_indexer.query_name(contributor)
            org =  event_data['company'] || fallback_org

            res =  repo_contributions.map do |repos|
              repo = repos[:repo_url]
              contribution = repos[:contribution]

              roles = []
              if manage_repo.include?(repo)
                roles << (org.present? ? 'organization_manager' : 'individual_manager')
              end

              unless manage_repo.include?(repo)
                roles << (org.present? ? 'organization_participant' : 'individual_participant')
              end
              roles << (core_repo.include?(repo) ? 'core' : 'guest')

              {
                repo_url: repo,
                repo: repo,
                contribution:contribution,
                roles: roles
              }
            end
            res
          end

          desc 'Developer Contribution Type Distribution / 开发者贡献类型占比',
               detail: 'Distribution of different types of developer contributions / 开发者贡献类型占比',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201, model: Openapi::Entities::ContributionTypeResponse
               }
          params {
            use :contributor_portrait_search
          }
          post :contribution_type do
            begin_date = params[:begin_date]
            end_date = params[:end_date]
            contributor = params[:contributor]

            enrich_indexer = GithubEventContributorRepoEnrich
            resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
            sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []

            # commit 数
            commit_count = sources.sum { |item| item['push_contribution'].to_i }

            # pr 数
            pr_fields = [
              'pull_request_opened_contribution',
              'pull_request_reopened_contribution',
              'pull_request_closed_contribution',
              'pull_request_merged_contribution',
            ]
            pr_count = sources.sum do |item|
              pr_fields.sum { |field| item[field].to_i }
            end

            # pr comment
            pr_comment_count = sources.sum { |item| item['pull_request_review_commented_contribution'].to_i }

            # issue 数
            issue_fields = [
              'issues_opened_contribution',
              'issues_reopened_contribution',
              'issues_closed_contribution',
            ]
            issue_count = sources.sum do |item|
              issue_fields.sum { |field| item[field].to_i }
            end

            issue_comment = sources.sum { |item| item['issue_comment_created_contribution'].to_i }

            # code review 计算
            code_review_fields = [
              'pull_request_review_approved_contribution',
              'pull_request_review_commented_contribution',
              'pull_request_review_changes_requested_contribution'
            ]
            code_review_count = sources.sum do |item|
              code_review_fields.sum { |field| item[field].to_i }
            end

            # 总贡献数
            total = commit_count + pr_count + pr_comment_count + issue_count + issue_comment + code_review_count

            # 防止除以 0
            total = 1 if total == 0
            percent = ->(val) { ((val.to_f / total) * 100).round(2) }

            {
              commit: percent.call(commit_count),
              pr: percent.call(pr_count),
              pr_comment: percent.call(pr_comment_count),
              issue: percent.call(issue_count),
              issue_comment: percent.call(issue_comment),
              code_review: percent.call(code_review_count),

            }
          end

          desc 'Monthly Code Commit Count / 开发者每月代码提交次数',
               detail: 'Number of code commits by developer per month / 开发者每月代码提交次数',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201,model: Openapi::Entities::ContributorMonthlyResponse

               }
          params {
            use :contributor_portrait_search
          }
          post :monthly_commit_counts do
            contributor = params[:contributor]
            begin_date = params[:begin_date]
            end_date = params[:end_date]

            enrich_indexer = GithubEventContributorRepoEnrich

            resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
            sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []

            # 统计 push_contribution 的每月值
            monthly_commit_data = aggregate_monthly_values(sources, end_date, ['push_contribution'])
            monthly_commit_data
          end

          desc 'Monthly Issue Update Count / 开发者每月更新issue次数',
               detail: 'Number of issue updates by developer per month / 开发者每月更新issue次数',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201,model: Openapi::Entities::ContributorMonthlyResponse

               }
          params {
            use :contributor_portrait_search
          }
          post :monthly_update_issues do
            contributor = params[:contributor]
            begin_date = params[:begin_date]
            end_date = params[:end_date]

            enrich_indexer = GithubEventContributorRepoEnrich

            resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
            sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []

            monthly_update_issue_data = aggregate_monthly_values(sources, end_date, ['issues_opened_contribution', 'issues_reopened_contribution', 'issues_closed_contribution'])
            monthly_update_issue_data
          end

          desc 'Monthly Issue Comment Count / 开发者每月issue评论次数',
               detail: 'Number of issue comments by developer per month / 开发者每月issue评论次数',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201,model: Openapi::Entities::ContributorMonthlyResponse

               }
          params {
            use :contributor_portrait_search
          }
          post :monthly_issue_comments do
            contributor = params[:contributor]
            begin_date = params[:begin_date]
            end_date = params[:end_date]

            enrich_indexer = GithubEventContributorRepoEnrich

            resp = enrich_indexer.list(contributor, begin_date, end_date, page: 1, per: MAX_PER)
            sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []

            monthly_issue_comments_data = aggregate_monthly_values(sources, end_date, ['issue_comment_created_contribution'])
            monthly_issue_comments_data
          end

          desc 'Developer Repository Contributions / 开发者对仓库贡献',
               detail: 'Developer contributions to repository including code, issues, issue comments, PR contributions and PR reviews / 开发者对仓库的代码贡献, Issue贡献, Issue评论, PR贡献以及PR审核贡献',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
               success: {
                 code: 201, model: Openapi::Entities::ContributorPortraitRepoCollaborationResponse
               }
          params {
            use :contributor_portrait_search
          }
          post :repo_collaboration do
            indexer = GithubEventContributorRepoEnrich
            event_repo_indexer = GithubEventRepositoryEnrich
            event_indexer = GithubEventContributor
            contributor = params[:contributor]
            resp = indexer.list(params[:contributor], params[:begin_date], params[:end_date], page: 1, per: MAX_PER)
            hits = resp&.[]('hits')&.[]('hits') || []
            sources = hits&.map { |hit| hit['_source'] } || []

            core_repo = event_repo_indexer.query_core_project(params[:contributor], params[:begin_date], params[:end_date], page: 1, per: MAX_PER)

            manage_repo = indexer.get_manage_repos(sources)

            fallback_org = sources.map { |s| s['contributor_org'] }.compact.find { |c| !c.to_s.strip.empty? }
            event_data = event_indexer.query_name(contributor)
            org =  event_data['company'] || fallback_org

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
                'total_contribution' => 0,
                'repo_roles' => []
              }
              roles = []

              if manage_repo.include?(repo)
                roles << (org.present? ? 'organization_manager' : 'individual_manager')
              end

              unless manage_repo.include?(repo)
                roles << (org.present? ? 'organization_participant' : 'individual_participant')
              end
              roles << (core_repo.include?(repo) ? 'core' : 'guest')

              result[repo]['repo_roles'] = roles.uniq

              contribution_map = {
                'push_contribution' => ['push_contribution'],
                'pull_request_contribution' => [
                  'pull_request_opened_contribution',
                  'pull_request_reopened_contribution',
                  'pull_request_closed_contribution',
                  'pull_request_merged_contribution'
                ],
                'pull_request_comment_contribution' => ['pull_request_review_commented_contribution'],
                'issue_contribution' => ['issues_opened_contribution', 'issues_reopened_contribution', 'issues_closed_contribution'],
                'issue_comment_contribution' => ['issue_comment_created_contribution']
              }

              contribution_map.each do |target_field, source_fields|
                source_fields.each do |source_field|
                  result[repo][target_field] += data[source_field].to_i
                end
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

          desc 'Developer Collaboration / 开发者协作',
               detail: 'Establish collaboration relationships with other developers through issues, PRs and their corresponding comments / 通过Issue、PR及其对应的评论信息，与其他开发者建立协作关系',
               tags: ['Metrics Data / 指标数据', 'Contributor Persona / 开发者画像'],
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
