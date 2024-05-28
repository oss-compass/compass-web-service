# frozen_string_literal: true

module Input
  class CommitFeedbackInput < Types::BaseInputObject
    argument :repo_name, String, required: true, description: "Repository name"
    argument :commit_hash, String, description: "Git commit hash"
    argument :new_lines_added, Integer, description: "Modify the number of deleted code"
    argument :new_lines_removed, Integer, description: "Modify the number of deleted code"
    argument :contact_way, String, description: "Modified code to changed the number of lines"
    argument :submit_reason, String, description: "Reasons for feedback"
    argument :request_reviewer_email, String, description: "Request reviewer's email"
  end
end
