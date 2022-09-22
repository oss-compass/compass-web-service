module Mutations
  class CreateProjectTask < BaseMutation
    graphql_name 'CreateProjectTask'

    field :status, String, null: false
    field :pr_url, String, null: true

    argument :username, String, required: true, description: 'gitee or github login/username'
    argument :project_name, String, required: true, description: 'project label for following repositories'
    argument :project_types, [Input::ProjectTypeInput], required: true, description: 'project detail information'
    argument :origin, String, required: true, description: "user's origin (gitee/github)"
    argument :token, String, required: true, description: "user's oauth token only for username verification"

    def resolve(username:, project_name:, project_types:, origin:, token:)
      yaml_template = {}
      yaml_template['organization_name'] = project_name
      yaml_template['project_types'] =
        project_types.reduce({}) do |result, type|
        result.merge({ type.type => { 'data_sources' => { 'repo_names' => type.repo_list }}})
      end
      raw_yaml = YAML.dump(yaml_template)
      result =
        AnalyzeGroupServer.new(
          {
            raw_yaml: raw_yaml,
            raw: true,
            enrich: true,
            activity: true,
            community: true,
            codequality: true,
          }
        ).execute(only_validate: true)

      case result
          in {status: :error}
          return { status: false, message: result[:message], pr_url: nil }
      else
        result =
          PullServer.new(
            {
              label: project_name,
              level: 'project',
              project_types: project_types,
              extra: { username: username, origin: origin, token: token }
            }
          ).execute
        OpenStruct.new(result.reverse_merge({pr_url: nil, message: '', status: true}))
      end
    end
  end
end
