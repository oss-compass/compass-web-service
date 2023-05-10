module Mutations
  class CreateRepoTask < BaseMutation
    graphql_name 'CreateRepoTask'

    field :status, String, null: false
    field :pr_url, String, null: true
    field :report_url, String, null: true

    argument :repo_urls, [String], required: true, description: 'repository urls'
    argument :origin, String, required: true, description: "user's origin (gitee/github)"

    def resolve(repo_urls:, origin:)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      username = LoginBind.current_host_nickname(current_user, origin)
      raise GraphQL::ExecutionError.new I18n.t('users.require_bind', provider: origin) if username.blank?

      result =
        PullServer.new(
          {
            level: 'repo',
            project_urls: repo_urls,
            extra: { username: username, origin: origin }
          }
        ).execute
      OpenStruct.new(result.reverse_merge({ pr_url: nil, message: '', status: true, report_url: nil }))
    end
  end
end
