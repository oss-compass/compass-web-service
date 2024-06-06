# frozen_string_literal: true

module Mutations
  class ModifyOrganization < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
    argument :old_org_name, String, required: false, description: 'Name of organization before modification'
    argument :org_name, String, required: true, description: 'Organization name'
    argument :domain, [String], required: true, description: 'Email suffix'

    def resolve(label: nil, level: 'repo', old_org_name: nil, org_name: nil, domain: [])
      label = ShortenedLabel.normalize_label(label)
      validate_repo_admin!(context[:current_user], label, level)

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
