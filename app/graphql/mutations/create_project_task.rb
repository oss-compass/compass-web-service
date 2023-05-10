module Mutations
  class CreateProjectTask < BaseMutation
    graphql_name 'CreateProjectTask'

    field :status, String, null: false
    field :pr_url, String, null: true
    field :report_url, String, null: true

    argument :project_name, String, required: true, description: 'project label for following repositories'
    argument :project_types, [Input::ProjectTypeInput], required: true, description: 'project detail information'
    argument :origin, String, required: true, description: "user's origin (gitee/github)"

    def resolve(project_name:, project_types:, origin:)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      username = LoginBind.current_host_nickname(current_user, origin)
      raise GraphQL::ExecutionError.new I18n.t('users.require_bind', provider: origin) if username.blank?

      yaml_template = {}
      yaml_template['community_name'] = project_name
      yaml_template['resource_types'] =
        project_types.reduce({}) do |result, type|
        result.merge({type.type => { 'repo_urls' => type.repo_list }})
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
            group_activity: true,
          }
        ).execute(only_validate: true)

      case result
          in {status: :error}
          return OpenStruct.new({ status: false, message: result[:message], pr_url: nil, report_url: nil })
      else
        result =
          PullServer.new(
            {
              label: project_name,
              level: 'community',
              project_types: project_types,
              extra: { username: username, origin: origin }
            }
          ).execute
        OpenStruct.new(result.reverse_merge({ pr_url: nil, message: '', status: true, report_url: nil }))
      end
    end
  end
end
