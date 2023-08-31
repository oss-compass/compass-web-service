module Mutations
  class CreateProjectTask < BaseMutation
    graphql_name 'CreateProjectTask'

    field :status, String, null: false
    field :pr_url, String, null: true
    field :report_url, String, null: true

    argument :project_name, String, required: true, description: 'project label for following repositories'
    argument :project_types, [Input::ProjectTypeInput], required: true, description: 'project detail information'
    argument :origin, String, required: true, description: "user's origin (gitee/github)"
    argument :project_url, String, required: false, description: 'project homepage url'
    argument :project_logo_url, String, required: false, description: 'project logo url'

    def resolve(project_name:, project_types:, origin:, project_url: nil, project_logo_url: nil)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      username = LoginBind.current_host_nickname(current_user, origin)
      raise GraphQL::ExecutionError.new I18n.t('users.require_bind', provider: origin) if username.blank?

      yaml_template = {}
      yaml_template['community_name'] = project_name
      yaml_template['community_logo_url'] = project_logo_url if project_logo_url
      yaml_template['community_org_url'] = project_url if project_url
      yaml_template['resource_types'] =
        project_types.reduce({}) do |result, type|
          result.merge({ type.type => { 'repo_urls' => type.repo_list } })
        end
      raw_yaml = YAML.dump(yaml_template)

      analyze_group_server = AnalyzeGroupServer.new(
        {
          raw_yaml: raw_yaml,
          raw: true,
          enrich: true,
          activity: true,
          community: true,
          codequality: true,
          group_activity: true,
        }
      )

      subject = Subject.find_or_create_by(label: project_name) do |subject|
        subject.level = 'community'
        subject.status = Subject::PENDING
        subject.count = analyze_group_server.repos_count
        subject.status_updated_at = Time.current
      end

      subscription = current_user.subscriptions.find_by(subject_id: subject.id)
      if subscription.blank?
        subscription = Subscription.new({ subject_id: subject.id, user_id: current_user.id })
        subscription.skip_notify_subscription = true
        subscription.save
        NotificationService.new(current_user, NotificationService::SUBMISSION, { subject: subject }).execute
      end
      result = analyze_group_server.execute(only_validate: true)

      case result
      in { status: :error }
        return OpenStruct.new({ status: false, message: result[:message], pr_url: nil, report_url: nil })
      else
        result =
          PullServer.new(
            {
              label: project_name,
              level: 'community',
              project_types: project_types,
              extra: { username: username, origin: origin, community_org_url: project_url, community_logo_url: project_logo_url }
            }
          ).execute
        OpenStruct.new(result.reverse_merge({ pr_url: nil, message: '', status: true, report_url: nil }))
      end
    end
  end
end
