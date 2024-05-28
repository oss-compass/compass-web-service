# frozen_string_literal: true

module Mutations
  class DeleteOrganization < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :org_name, String, required: true, description: 'Organization name'

    def resolve(org_name: nil)
      validate_admin!(context[:current_user])

      if org_name && !org_name.empty?
        Organization.delete_by_org_name(org_name)
      end

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
