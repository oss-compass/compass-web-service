# frozen_string_literal: true
module IssueEnrich
  extend ActiveSupport::Concern
  class_methods do
    def export_headers
      ['title', 'url', 'state', 'created_at', 'closed_at', 'time_to_close_days', 'time_to_first_attention_without_bot',
       'num_of_comments_without_bot', 'labels', 'user_login', 'assignee_login']
    end

    def on_each(args)
      source = args[:source]
      source['labels'] = source['labels'].join('|') if source['labels'].is_a?(Array)
      source
    end
  end
end
