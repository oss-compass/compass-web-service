# frozen_string_literal: true

module Types
  module Meta
    class CommitFeedbackType < Types::BaseObject
      field :id, String
      field :repo_name, String
      field :commit_hash, String
      field :pr_url, String
      field :old_lines_added, Integer
      field :old_lines_removed, Integer
      field :old_lines_changed, Integer
      field :new_lines_added, Integer
      field :new_lines_removed, Integer
      field :new_lines_changed, Integer
      field :contact_way, String
      field :submit_reason, String
      field :submit_user_id, String
      field :submit_user_email, String
      field :request_reviewer_email, String
      field :reviewer_id, String
      field :reviewer_email, String
      field :review_msg, String
      field :state, String
      field :create_at_date, GraphQL::Types::ISO8601DateTime
      field :update_at_date, GraphQL::Types::ISO8601DateTime
    end
  end
end
