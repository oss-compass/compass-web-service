module Mutations
  class CreateRepoTask < BaseMutation
    graphql_name 'CreateRepoTask'

    field :status, String, null: false
    field :pr_url, String, null: true

    argument :username, String, required: true, description: 'gitee or github login/username'
    argument :repo_urls, [String], required: true, description: 'repository urls'
    argument :origin, String, required: true, description: "user's origin (gitee/github)"
    argument :token, String, required: true, description: "user's oauth token only for username verification"

    def resolve(username:, repo_urls:, origin:, token:)
      result =
        PullServer.new(
          {
            level: 'repo',
            project_urls: repo_urls,
            extra: { username: username, origin: origin, token: token }
          }
        ).execute
      OpenStruct.new(result.reverse_merge({pr_url: nil, message: '', status: true}))
    end
  end
end
