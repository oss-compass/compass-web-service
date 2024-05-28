# frozen_string_literal: true

module Mutations
  class ReviewCommitFeedback < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
    argument :id, String, required: true, description: 'Commit feedback id'
    argument :review_msg, String, required: true, description: 'Review comments'
    argument :state, String, required: true, description: "Review conclusions: 'approved', 'rejected' ,default: 'approved'"

    def resolve(label: nil, level: 'repo', id: nil, review_msg: nil, state: 'approved')
      label = ShortenedLabel.normalize_label(label)
      validate_admin!(context[:current_user])

      indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, CommitFeedback, CommitFeedback)
      commit_feedback_data = indexer.fetch_commit_feedback_one(repo_urls, id)
      raise GraphQL::ExecutionError.new I18n.t('commit_feedback.invalid_commit_id') if commit_feedback_data.nil?

      commit_feedback_data["reviewer_id"] = context[:current_user].id
      commit_feedback_data["reviewer_email"] = context[:current_user].email
      commit_feedback_data["review_msg"] = review_msg
      commit_feedback_data["state"] = state
      commit_feedback_data["update_at_date"] = Time.current

      record = OpenStruct.new(commit_feedback_data.transform_keys(&:to_sym))
      CommitFeedback.import(record)

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
