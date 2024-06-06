# frozen_string_literal: true

module Mutations
  class DeleteOrganization < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
    argument :org_name, String, required: true, description: 'Organization name'

    def resolve(label: nil, level: 'repo',org_name: nil)
      label = ShortenedLabel.normalize_label(label)
      validate_repo_admin!(context[:current_user], label, level)

      if org_name && !org_name.empty?
        Organization.delete_by_org_name(org_name)
      end

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
