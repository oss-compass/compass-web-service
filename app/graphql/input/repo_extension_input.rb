# frozen_string_literal: true

module Input
  class RepoExtensionInput < Types::BaseInputObject
    argument :repo_name, String, required: true, description: "Repository name"
    argument :repo_technology_type, String, description: "Technical field of the Repository"
    argument :repo_attribute_type, String, description: "Repository attribute type, either self-developed or third-party"
    argument :manager, String, description: "Repository manager or administrator"
    argument :manager_email, String, description: "Repository manager email or administrator email"
  end
end
