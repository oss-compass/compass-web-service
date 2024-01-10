# frozen_string_literal: true

module Mutations
  class ModifyUserOrgs < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :platform, String, required: true, description: 'platform of the organization'
    argument :organizations, [Input::ContributorOrgInput], required: true, description: 'contributor organizations'

    def resolve(platform: nil, organizations: [])
      current_user = context[:current_user]

      login_required!(current_user)

      Input::ContributorOrgInput.validate_no_overlap(organizations)

      login_bind = current_user.login_binds.find_by(provider: platform)
      raise GraphQL::ExecutionError.new I18n.t('users.no_such_login_bind') if login_bind.blank?
      contributor = login_bind.nickname
      uuid = get_uuid(contributor, ContributorOrg::UserIndividual, nil, nil, platform)
      record = OpenStruct.new(
        {
          id: uuid,
          uuid: uuid,
          org_change_date_list: organizations,
          modify_by: current_user.id,
          modify_type: ContributorOrg::UserIndividual,
          platform_type: platform,
          is_bot: false,
          label: nil,
          level: nil,
          update_at_date: Time.current
        }
      )

      ContributorOrg.import(record)

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
