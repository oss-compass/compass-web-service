# frozen_string_literal: true

module Mutations
  class AddRepoExtension < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :repo_extension_list, [Input::RepoExtensionInput], required: true, description: 'repo extension'

    def resolve(repo_extension_list: [])

      validate_admin!(context[:current_user])

      record_list = repo_extension_list.map do |data|
        uuid = get_uuid(data[:repo_name])
        record = OpenStruct.new(
          {
            id: uuid,
            uuid: uuid,
            repo_name: data[:repo_name],
            repo_technology_type: data[:repo_technology_type],
            repo_attribute_type: data[:repo_attribute_type],
            manager: data[:manager],
            manager_email: data[:manager_email],
            platform_type: Addressable::URI.parse(data[:repo_name]).normalized_host.split('.')[-2],
            operator: context[:current_user].id,
            update_at_date: Time.current
          }
        )
        record
      end
      RepoExtension.import(record_list)

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
