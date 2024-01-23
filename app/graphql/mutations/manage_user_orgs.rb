# frozen_string_literal: true

module Mutations
  class ManageUserOrgs < BaseMutation
    include CompassUtils

    field :status, String, null: false
    field :pr_url, String, null: true

    argument :contributor, String, required: true, description: 'name of the contributor'
    argument :platform, String, required: true, description: 'platform of the organization'
    argument :label, String, required: true, description: 'repo or community label'
    argument :level, String, required: false, description: 'repo or community level', default_value: 'repo'
    argument :organizations, [Input::ContributorOrgInput], required: true, description: 'contributor organizations'

    def resolve(contributor: nil, platform: nil, label: nil, level: 'repo', organizations: [])

      current_user = context[:current_user]

      login_required!(current_user)

      Input::ContributorOrgInput.validate_no_overlap(organizations)

      label = ShortenedLabel.normalize_label(label)

      if current_user.is_admin?
        uuid = get_uuid(contributor, ContributorOrg::SystemAdmin, label, level, platform)
        record = OpenStruct.new(
          {
            id: uuid,
            uuid: uuid,
            contributor: contributor,
            org_change_date_list: organizations,
            modify_by: current_user.id,
            modify_type: ContributorOrg::SystemAdmin,
            platform_type: platform,
            is_bot: false,
            label: label,
            level: level,
            update_at_date: Time.current
          }
        )
        ContributorOrg.import(record)
        { status: true, message: '', pr_url: nil }
      elsif is_repo_admin?(current_user, label, level)
        login_bind = current_user.login_binds.find_by(provider: platform)
        raise GraphQL::ExecutionError.new I18n.t('users.no_such_login_bind') if login_bind.blank?
        result =
          PullServer.new(
            {
              label: label,
              level: level,
              extra: {
                username: login_bind.nickname,
                origin: platform,
                contributor: contributor,
                organizations: organizations
              }
            }
          ).update_developers
        result.reverse_merge({ pr_url: nil, message: '', status: true })
      else
        raise GraphQL::ExecutionError.new I18n.t('users.no_permission')
      end

    rescue => ex
      { status: false, message: ex.message, pr_url: nil }
    end
  end
end
