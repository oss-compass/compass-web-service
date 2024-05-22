# frozen_string_literal: true
module PullEnrich
  extend ActiveSupport::Concern
  class_methods do

    MAX_PER_PAGE = 10000

    def export_headers
      ['title', 'url', 'state', 'created_at', 'closed_at', 'time_to_close_days', 'time_to_first_attention_without_bot',
       'num_of_comments_without_bot', 'labels', 'user_login', 'reviewers_login', 'merge_author_login']
    end

    def on_each(args)
      source = args[:source]
      source['labels'] = source['labels'].join('|') if source['labels'].is_a?(Array)
      source
    end

    def list_by_repo_urls(repo_urls, begin_date, end_date, target: 'tag',
                          filter: :merged_at, sort: :merged_at, direction: :asc, filter_opts: [], sort_opts: [],
                          commit_hash_list: [])
      base = base_terms_by_repo_urls(repo_urls, begin_date, end_date, target: target,
                              filter: filter, sort: sort, direction: direction, filter_opts: filter_opts, sort_opts: sort_opts)
      if commit_hash_list.present?
        base = base.where( commits_data: commit_hash_list)
      end
      base.where( state: 'merged')
          .per(MAX_PER_PAGE)
          .execute
          .raw_response
    end

  end
end
