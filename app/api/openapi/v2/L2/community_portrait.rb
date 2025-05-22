# frozen_string_literal: true

module Openapi
  module V2
    module L2
      class CommunityPortrait < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json


        helpers Openapi::SharedParams::CustomMetricSearch
        helpers Openapi::SharedParams::AuthHelpers

        before { require_token! }

        resource :community_portrait do

          #代码
          desc '在过去 90 天内至少提交了一次代码的周百分比 (单仓场景)。在过去 30 天内至少有一次代码提交记录的的代码仓百分比 (多仓场景)',
               detail: '代码是否维护',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :is_maintained do
            fetch_metric_data(metric_name: "is_maintained")
          end

          desc '过去 90 天内平均每周代码提交次数',
               detail: '代码提交频率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :commit_frequency do
            fetch_metric_data(metric_name: "commit_frequency")
          end

          desc '最近1年中每季度的代码贡献量情况',
               detail: '代码季度提交量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :activity_quarterly_contribution do
            fetch_metric_data(metric_name: "activity_quarterly_contribution")
          end

          desc '使用者在修改源码后是否允许对修改部分进行闭源',
               detail: '代码是否允许闭源',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :license_commercial_allowed do
            fetch_metric_data(metric_name: "license_commercial_allowed")
          end

          desc '在过去 90 天内提交的代码次数',
               detail: '代码提交量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :commit_count do
            fetch_metric_data(metric_name: "commit_count")
          end

          desc '在过去 90 天内提交的代码链接 PR 的百分比。',
               detail: '代码提交关联PR的比率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :commit_pr_linked_ratio do
            fetch_metric_data(metric_name: "commit_pr_linked_ratio")
          end

          desc '过去 90 天内提交的代码链接 PR 的次数。',
               detail: '代码链接PR量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :commit_pr_linked_count do
            fetch_metric_data(metric_name: "commit_pr_linked_count")
          end

          desc '过去 90 天内平均每周提交的代码行数 (增加行数加上删除行数)。',
               detail: '代码变更行数',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :lines_of_code_frequency do
            fetch_metric_data(metric_name: "lines_of_code_frequency")
          end

          desc '确定在过去 90 天内平均每周提交的代码行数 (增加行数)。',
               detail: '代码增加行数',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :lines_add_of_code_frequency do
            fetch_metric_data(metric_name: "lines_add_of_code_frequency")
          end

          desc '确定在过去 90 天内平均每周提交的代码行数 (删除行数)。',
               detail: '代码删除行数',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :lines_remove_of_code_frequency do
            fetch_metric_data(metric_name: "lines_remove_of_code_frequency")
          end

          desc '组织数量: 过去 90 天内活跃的代码提交者所属组织的数目。',
               detail: '组织数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_count do
            fetch_metric_data(metric_name: "org_count")
          end

          desc '组织代码提交频率: 过去 90 天内平均每周有组织归属的代码提交次数。',
               detail: '组织代码提交频率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_commit_frequency do
            fetch_metric_data(metric_name: "org_commit_frequency")
          end

          desc '组织持续贡献: 在过去 90 天所有组织向社区有代码贡献的累计时间（周）。',
               detail: '组织持续贡献',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_contribution_last do
            fetch_metric_data(metric_name: "org_contribution_last")
          end

          desc '组织贡献度: 评估组织、机构对开源软件的贡献情况。',
               detail: '组织贡献度',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_contribution do
            fetch_metric_data(metric_name: "org_contribution")
          end

          desc '在过去 90 天内有多少活跃的代码提交者、代码审核者和 PR 提交者',
               detail: '代码贡献者数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :code_contributor_count do
            fetch_metric_data(metric_name: "code_contributor_count")
          end

          desc '过去 90 天中活跃的代码提交者的数量。',
               detail: '代码提交者数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :commit_contributor_count do
            fetch_metric_data(metric_name: "commit_contributor_count")
          end

          # Issue
          desc '过去 90 天新建 Issue 首次响应时间的均值和中位数（天）。这不包括机器人响应、创建者自己的评论或 Issue 的分配动作（action）。如果 Issue 一直未被响应，该 Issue 不被算入统计。',
               detail: 'Issue 首次响应时间',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :issue_first_reponse do
            fetch_metric_data(metric_name: "issue_first_reponse")
          end

          desc '过去 90 天新建的 Bug 类 Issue 处理时间的均值和中位数（天），包含已经关闭的 Issue 以及未解决的 Issue。',
               detail: 'Issue Bug类处理时间',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :bug_issue_open_time do
            fetch_metric_data(metric_name: "bug_issue_open_time")
          end

          desc '过去 90 天内新建 Issue 的评论平均数（不包含机器人和 Issue 作者本人评论）',
               detail: 'Issue评论频率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :comment_frequency do
            fetch_metric_data(metric_name: "comment_frequency")
          end

          desc '过去 90 天关闭 Issue 的数量。',
               detail: 'Issue关闭数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :closed_issues_count do
            fetch_metric_data(metric_name: "closed_issues_count")
          end

          desc '过去 90 天 Issue 更新的数量。',
               detail: 'Issue更新数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :updated_issues_count do
            fetch_metric_data(metric_name: "updated_issues_count")
          end

          desc '过去 90 天中活跃的 Issue 作者的数量',
               detail: 'Issue作者数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :issue_authors_contributor_count do
            fetch_metric_data(metric_name: "issue_authors_contributor_count")
          end

          desc '过去 90 天中活跃的 Issue 评论者的数量',
               detail: 'Issue评论者数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :issue_comments_contributor_count do
            fetch_metric_data(metric_name: "issue_comments_contributor_count")
          end

          # PR
          desc '过去 90 天新建 PR 的处理时间的均值和中位数（天），包含已经关闭的 PR 以及未解决的 PR。',
               detail: 'PR处理时间',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :pr_open_time do
            fetch_metric_data(metric_name: "pr_open_time")
          end

          desc '过去 90 天内新建 PR 的评论平均数量（不包含机器人和 PR 作者本人评论）。',
               detail: 'PR审查评论频率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :code_review_count do
            fetch_metric_data(metric_name: "code_review_count")
          end

          desc '过去 90 天内合并和拒绝的 PR 数量。',
               detail: 'PR关闭数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :close_pr_count do
            fetch_metric_data(metric_name: "close_pr_count")
          end

          desc '在过去 90 天内，从创建 PR 到首次收到人工回复的时间间隔。',
               detail: 'PR首次响应时间',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :pr_time_to_first_response do
            fetch_metric_data(metric_name: "pr_time_to_first_response")
          end

          desc '从开始到现在 PR 总数与关闭的 PR 数之间的比率。',
               detail: 'PR闭环总比率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :change_request_closure_ratio do
            fetch_metric_data(metric_name: "change_request_closure_ratio")
          end

          desc '过去 90 天内提交代码中，至少包含一名审核者 (不是 PR 创建者) 的百分比。',
               detail: 'PR审查比率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :code_review_ratio do
            fetch_metric_data(metric_name: "code_review_ratio")
          end

          desc '过去 90 天内创建的 PR 的数量。',
               detail: 'PR创建数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :pr_count do
            fetch_metric_data(metric_name: "pr_count")
          end

          desc '在过去 90 天内审查的 PR 数量。',
               detail: 'PR审查数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :pr_count_with_review do
            fetch_metric_data(metric_name: "pr_count_with_review")
          end

          desc '过去 90 天提交代码中，PR 合并者和 PR 作者不属于同一人的百分比。',
               detail: 'PR合并比率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :code_merge_ratio do
            fetch_metric_data(metric_name: "code_merge_ratio")
          end

          desc ' 过去 90 天内新建 PR 关联 Issue 的百分比。',
               detail: 'PR关联Issue的比率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :pr_issue_linked_ratio do
            fetch_metric_data(metric_name: "pr_issue_linked_ratio")
          end

          desc '从开始到现在创建的 PR 并且被接受或拒绝的数量。',
               detail: 'PR已接受或拒绝总数',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :total_create_close_pr_count do
            fetch_metric_data(metric_name: "total_create_close_pr_count")
          end

          desc 'PR总数: 从开始到现在新建 PR 数量。',
               detail: 'PR总数',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :total_pr_count do
            fetch_metric_data(metric_name: "total_pr_count")
          end

          desc '过去 90 天内创建的 PR 并且被接受或拒绝的数量。',
               detail: 'PR已接受或拒绝数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :create_close_pr_count do
            fetch_metric_data(metric_name: "create_close_pr_count")
          end

          desc '过去 90 天内 PR 合并数量（不包含 PR 作者本人合并）。',
               detail: 'PR合并数量(非PR作者合并)',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :code_merge_count_with_non_author do
            fetch_metric_data(metric_name: "code_merge_count_with_non_author")
          end

          desc 'PR关联Issue数量: 过去 90 天内新建 PR 关联 Issue 的数量。',
               detail: 'PR关联Issue数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :pr_issue_linked_count do
            fetch_metric_data(metric_name: "pr_issue_linked_count")
          end

          desc 'Pull Request 作者数量。',
               detail: 'PR作者数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :pr_authors_contributor_count do
            fetch_metric_data(metric_name: "pr_authors_contributor_count")
          end

          desc '过去 90 天中活跃的代码审查者的数量',
               detail: 'PR审查者数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :pr_review_contributor_count do
            fetch_metric_data(metric_name: "pr_review_contributor_count")
          end

          # 仓库
          desc '代码仓自创建以来存在了多长时间 (月份)',
               detail: '仓库创建于',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :created_since do
            fetch_metric_data(metric_name: "created_since")
          end

          desc '每个代码仓自上次更新以来的平均时间 (天)，即多久没更新了',
               detail: '仓库更新于',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :updated_since do
            fetch_metric_data(metric_name: "updated_since")
          end

          desc '评估开源软件开源许可证发生变更时是否需向用户进行声明。',
               detail: '仓库开源许可证变更声明',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :license_change_claims_required do
            fetch_metric_data(metric_name: "license_change_claims_required")
          end

          desc '评估项目是否为宽松型开源许可证或弱著作权开源许可证。',
               detail: '仓库宽松型或弱著作权开源许可证',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :license_is_weak do
            fetch_metric_data(metric_name: "license_is_weak")
          end

          desc '过去 12 个月版本发布的数量',
               detail: '仓库最近版本发布次数',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :recent_releases_count do
            fetch_metric_data(metric_name: "recent_releases_count")
          end

          # 贡献者
          desc '过去 90 天中活跃的代码提交者、Pull Request 作者、代码审查者、Issue 作者和 Issue 评论者的数量。',
               detail: '贡献者数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :contributor_count do
            fetch_metric_data(metric_name: "contributor_count")
          end

          desc '过去 90 天内贡献占 50% 的最小人数。',
               detail: '贡献者Bus Factor',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :bus_factor do
            fetch_metric_data(metric_name: "bus_factor")
          end

          # 组织
          desc '过去 90 天内活跃的代码提交者所属组织的数目。',
               detail: '组织数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_count do
            fetch_metric_data(metric_name: "org_count")
          end

          desc '过去 90 天内平均每周有组织归属的代码提交次数。',
               detail: '组织代码提交频率',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_commit_frequency do
            fetch_metric_data(metric_name: "org_commit_frequency")
          end

          desc '在过去 90 天所有组织向社区有代码贡献的累计时间（周）。',
               detail: '组织持续贡献',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_contribution_last do
            fetch_metric_data(metric_name: "org_contribution_last")
          end

          desc '评估组织、机构对开源软件的贡献情况。',
               detail: '组织贡献度',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_contribution do
            fetch_metric_data(metric_name: "org_contribution")
          end

          desc '组织贡献者数量: 过去 90 天内有组织附属关系的活跃的代码贡献者人数。',
               detail: '组织贡献者数量',
               tags: ['Metrics Data', 'Community Portrait']
          params { use :custom_metric_search }
          post :org_contributor_count do
            fetch_metric_data(metric_name: "org_contributor_count")
          end

        end
      end

    end
  end
end
