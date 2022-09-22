module Mutations
  class CreateRepoTask < BaseMutation
    graphql_name 'CreateRepoTask'

    field :status, String, null: false
    field :pr_url, String, null: true

    argument :username, String, required: true, description: 'gitee or github login/username'
    argument :repo_url, String, required: true, description: 'repository url'
    argument :origin, String, required: true, description: "user's origin (gitee/github)"
    argument :token, String, required: true, description: "user's oauth token only for username verification"

    def resolve(username:, repo_url:, origin:, token:)
      result =
        AnalyzeServer.new(
          {
            repo_url: repo_url,
            raw: true,
            enrich: true,
            activity: true,
            community: true,
            codequality: true,
          }
        ).execute(only_validate: true)

      unless result[:status]
        return { status: result[:status], message: result[:message] }
      end
      result =
        PullServer.new(
          {
            label: repo_url,
            level: 'repo',
            project_url: repo_url,
            extra: { username: username, origin: origin, token: token }
          }
        ).execute
      OpenStruct.new(result.reverse_merge({pr_url: nil, message: '', status: true}))
    end
  end
end
