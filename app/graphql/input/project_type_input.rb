# frozen_string_literal: true

module Input
  class ProjectTypeInput < Types::BaseInputObject
    argument :type, String, required: true, description: 'project type label'
    argument :repo_list, [String], required: true, description: "project's repositories list"
  end
end
