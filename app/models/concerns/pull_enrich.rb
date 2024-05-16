# frozen_string_literal: true
module PullEnrich
  extend ActiveSupport::Concern
  class_methods do
    def export_headers
      ['title', 'url', 'state', 'created_at', 'closed_at', 'time_to_close_days', 'time_to_first_attention_without_bot',
       'num_of_comments_without_bot', 'labels', 'user_login', 'reviewers_login', 'merge_author_login']
    end

    def on_each(args)
      source = args[:source]
      source['labels'] = source['labels'].join('|') if source['labels'].is_a?(Array)
      source
    end

    def map_by_commit_hash_list(commit_hash_list)
      resp = self.must(terms: { commits_data: commit_hash_list})
                 .per(commit_hash_list.length)
                 .execute
                 .raw_response
      hits = resp&.[]('hits')&.[]('hits') || []
      hits.each_with_object({}) do |hash, map|
        hash['_source']['commits_data'].each do |key|
          map[key] = hash['_source']
        end
      end
    end

  end
end
