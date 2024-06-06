# frozen_string_literal: true
module Pull2Enrich
  extend ActiveSupport::Concern
  class_methods do

    MAX_PER_PAGE = 10000
    def list_user_login_by_repo_urls(repo_urls, begin_date, end_date, target: 'tag',
                                     filter: :comment_created_at, sort: :comment_created_at, direction: :asc, filter_opts: [], sort_opts: [])
      base = base_terms_by_repo_urls(repo_urls, begin_date, end_date, target: target,
                                     filter: filter, sort: sort, direction: direction, filter_opts: filter_opts, sort_opts: sort_opts)
      resp = base.aggregate(group_by_name: { terms: { field: 'user_login', size: MAX_PER_PAGE }})
                 .where(pull_state: 'merged')
                 .where(comment_type: 'diff_comment')
                 .per(0)
                 .execute
                 .raw_response
      buckets = resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []
      buckets.map do |data|
        data['key']
      end
    end


    def fetch_check_agg_list_by_repo_urls(repo_urls, begin_date, end_date, target: 'tag',
                          filter: :comment_created_at, sort: :comment_created_at, direction: :asc, filter_opts: [], sort_opts: [],
                          user_login_list: [])
      base = base_terms_by_repo_urls(repo_urls, begin_date, end_date, target: target,
                              filter: filter, sort: sort, direction: direction, filter_opts: filter_opts, sort_opts: sort_opts)
      if user_login_list.present?
        base = base.where(user_login: user_login_list)
      end
      base.aggregate(
        group_by_name: {
          terms: { field: 'user_login', size: MAX_PER_PAGE },
          aggs: {
            group_by_pull_url: {
              terms: { field: 'pull_url', size: MAX_PER_PAGE },
              aggs: { top_hits: { top_hits: { size: 1, sort: [{ comment_created_at: { order: "desc" } }] } } }
            }
          }
        }
      )
          .where(pull_state: 'merged')
          .where(comment_type: 'diff_comment')
          .per(MAX_PER_PAGE)
          .execute
          .raw_response
    end

  end
end
