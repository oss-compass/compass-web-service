# frozen_string_literal: true

module Mutations
  class ModifyOrganization < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :old_org_name, String, required: false, description: 'Name of organization before modification'
    argument :org_name, String, required: true, description: 'Organization name'
    argument :domain, [String], required: true, description: 'Email suffix'

    def resolve(old_org_name: nil, org_name: nil, domain: [])
      validate_admin!(context[:current_user])

      if old_org_name && !old_org_name.empty?
        Organization.delete_by_org_name(old_org_name)
      end

      record_list = domain.map do |data|
        uuid = get_uuid(data, org_name)
        record = OpenStruct.new(
          {
            id: uuid,
            uuid: uuid,
            domain: data,
            org_name: org_name,
            user_id: context[:current_user].id,
            update_at_date: Time.current
          }
        )
        record
      end
      Organization.import(record_list)

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
