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

      login_required!(current_user)

      username = LoginBind.current_host_nickname(current_user, origin)
      raise GraphQL::ExecutionError.new I18n.t('users.require_bind', provider: origin) if username.blank?

      repo_urls.each do |repo_url|
        raise GraphQL::ExecutionError.new(I18n.t('analysis.validation.missing', field: 'repo_url')) unless repo_url.present?
        repo_url = repo_url.chomp('/')

        uri = Addressable::URI.parse(repo_url)
        unless Common::SUPPORT_DOMAINS.include?(uri&.normalized_host)
          raise GraphQL::ExecutionError.new(I18n.t('analysis.validation.not_support', source: repo_url))
        end

        subject = Subject.find_or_create_by(label: repo_url) do |subject|
          subject.level = 'repo'
          subject.status = Subject::PENDING
          subject.count = 1
          subject.status_updated_at = Time.current
        end
        subscription = current_user.subscriptions.find_by(subject_id: subject.id)
        if subscription.blank?
          subscription = Subscription.new({ subject_id: subject.id, user_id: current_user.id })
          subscription.skip_notify_subscription = true
          subscription.save
          NotificationService.new(current_user, NotificationService::SUBMISSION, { subject: subject }).execute
        end
      end

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
