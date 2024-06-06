# frozen_string_literal: true

module Mutations
  class CreateSubjectAccessLevel < BaseMutation

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
    argument :user_id, Integer, required: true, description: 'user id'
    argument :access_level, Integer, required: true, description: 'subject access level: `NORMAL/COMMITTER: 0, PRIVILEGED/LEADER: 1 default: 0`'

    def resolve(label: nil, level: 'repo', user_id: nil, access_level: 0)
      label = ShortenedLabel.normalize_label(label)

      validate_repo_admin!(context[:current_user], label, level)

      subject = Subject.find_by(label: label, level: level)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?

      SubjectAccessLevel.create!(
        {
          subject_id: subject.id,
          access_level: access_level,
          user_id: user_id
        }
      )

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
