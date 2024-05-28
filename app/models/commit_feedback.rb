# frozen_string_literal: true

class CommitFeedback < BaseIndex

  include BaseEnrich

  def self.index_name
    'commit_feedback'
  end

  def self.mapping
    {
      "properties"=> {
        "commit_hash"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "contact_way"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "create_at_date"=> { "type"=> "date"},
        "id"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "new_lines_added"=> { "type"=> "long"},
        "new_lines_changed"=> { "type"=> "long"},
        "new_lines_removed"=> { "type"=> "long"},
        "old_lines_added"=> { "type"=> "long"},
        "old_lines_changed"=> { "type"=> "long"},
        "old_lines_removed"=> { "type"=> "long"},
        "pr_url"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "repo_name"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "request_reviewer_email"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "review_msg"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "reviewer_email"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "reviewer_id"=> { "type"=> "long"},
        "state"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "submit_reason"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "submit_user_email"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}},
        "submit_user_id"=> { "type"=> "long"},
        "update_at_date"=> { "type"=> "date"},
        "uuid"=> { "type"=> "text","fields"=> { "keyword"=> { "type"=> "keyword","ignore_above"=> 256}}}
      }
    }
  end

  def self.fetch_commit_feedback_list(repo_urls, values, target: 'repo_name.keyword', value_field: 'id.keyword', state: nil)
    base = self.must(terms: { target => repo_urls })
               .must(terms: { value_field => values })
    if state.nil?
      base = base.where( 'state.keyword': state)
    end
    resp = base.per(values.length)
               .execute
               .raw_response
    (resp&.[]('hits')&.[]('hits') || []).map do |data|
      data["_source"]
    end
  end

  def self.fetch_commit_feedback_one(repo_urls, values, target: 'repo_name.keyword', value_field: 'id.keyword', state: nil)
    fetch_list = fetch_commit_feedback_list(repo_urls, values, target: target, value_field: value_field, state: state)
    fetch_list.first
  end


end
