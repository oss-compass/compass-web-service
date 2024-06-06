# frozen_string_literal: true

module Mutations
  class DeleteSubjectAccessLevel < BaseMutation
    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
    argument :id, Integer, required: true, description: "Subject access level id"

    def resolve(label: nil, level: 'repo', id: nil)
      label = ShortenedLabel.normalize_label(label)
      validate_repo_admin!(context[:current_user], label, level)

      subject_access_level = SubjectAccessLevel.find_by(id: id)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject_access_level.nil?

      subject_access_level.destroy!

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
