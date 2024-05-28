# frozen_string_literal: true

module Mutations
  class CreateCommitFeedback < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
    argument :commit_feedback_input, Input::CommitFeedbackInput, required: true, description: 'repo extension'

    def resolve(label: nil, level: 'repo', commit_feedback_input: nil)
      label = ShortenedLabel.normalize_label(label)
      login_required!(context[:current_user])

      git_indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)
      commit_data = git_indexer.fetch_commit_one_by_hash(repo_urls, commit_feedback_input[:commit_hash])
      raise GraphQL::ExecutionError.new I18n.t('commit_feedback.invalid_commit_hash') if commit_data.nil?

      pull_indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteePullEnrich, GithubGitEnrich)
      pull_data = pull_indexer.fetch_pull_one_by_hash(repo_urls, commit_feedback_input[:commit_hash])


      record = OpenStruct.new(
        {
          id: commit_data['uuid'],
          uuid: commit_data['uuid'],
          repo_name: commit_feedback_input[:repo_name],
          commit_hash: commit_feedback_input[:commit_hash],
          pr_url: pull_data&.[]('url'),
          old_lines_added: commit_data['lines_added'],
          old_lines_removed: commit_data['lines_removed'],
          old_lines_changed: commit_data['lines_changed'],
          new_lines_added: commit_feedback_input[:new_lines_added],
          new_lines_removed: commit_feedback_input[:new_lines_removed],
          new_lines_changed: commit_feedback_input[:new_lines_added] + commit_feedback_input[:new_lines_removed],
          contact_way: commit_feedback_input[:contact_way],
          submit_reason: commit_feedback_input[:submit_reason],
          submit_user_id: context[:current_user].id,
          submit_user_email: context[:current_user].email,
          request_reviewer_email: commit_feedback_input[:request_reviewer_email],
          reviewer_id: nil,
          reviewer_email: nil,
          review_msg: nil,
          state: 'created', # created, approved, rejected
          create_at_date: Time.current,
          update_at_date: Time.current
        }
      )

      CommitFeedback.import(record)

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
