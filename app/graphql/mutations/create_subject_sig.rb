# frozen_string_literal: true

module Mutations
  class CreateSubjectSig < BaseMutation

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
    argument :name, String, required: true, description: 'subject sig name'
    argument :description, String, required: false, description: 'subject sig description'
    argument :maintainers, [String], required: false, description: 'subject sig maintainers'
    argument :emails, [String], required: false, description: 'subject sig emails'
    argument :link_sig_label, String, required: true, description: 'link sig label'

    def resolve(label: nil,
                level: 'repo',
                name: nil,
                description: nil,
                maintainers: [],
                emails: [],
                link_sig_label: nil)
      label = ShortenedLabel.normalize_label(label)

      validate_repo_admin!(context[:current_user], label, level)

      name = name.strip
      raise GraphQL::ExecutionError.new I18n.t('subject_sig.invalid_name') if name.blank?
      subject = Subject.find_by(label: label, level: level)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?
      sig_subject = Subject.find_by(label: link_sig_label, level: "community")
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if sig_subject.nil?

      ActiveRecord::Base.transaction do
        subject_ref = SubjectRef.create!(
          {
            parent_id: subject.id,
            child_id: sig_subject.id,
            sub_type: SubjectRef::ToSig
          }
        )
        subject_ref.create_subject_sig!(
          {
            name: name,
            description: description,
            maintainers: maintainers.any? ? maintainers.to_json : nil,
            emails: maintainers.any? ? emails.to_json : nil
          }
        )
      end

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
