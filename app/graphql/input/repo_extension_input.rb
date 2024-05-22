# frozen_string_literal: true

module Input
  class RepoExtensionInput < Types::BaseInputObject
    argument :repo_name, String, required: true, description: "repo name"
    argument :repo_technology_type, String, description: "Technical field of the repo"
    argument :repo_attribute_type, String, description: "repo attribute type, either self-developed or third-party"
    argument :manager, String, description: "Warehouse manager or administrator"
    argument :manager_email, String, description: "Warehouse manager email or administrator email"
  end
end
