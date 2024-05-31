# frozen_string_literal: true

module Mutations
  class UpdateSubjectSig < BaseMutation

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
    argument :id, Integer, required: true, description: "Subject sig id"
    argument :name, String, required: true, description: 'subject sig name'
    argument :description, String, required: false, description: 'subject sig description'
    argument :maintainers, [String], required: false, description: 'subject sig maintainers'
    argument :emails, [String], required: false, description: 'subject sig emails'
    argument :link_sig_label, String, required: true, description: 'link sig label'

    def resolve(label: nil,
                level: 'repo',
                id: nil,
                name: nil,
                description: nil,
                maintainers: [],
                emails: [],
                link_sig_label: nil)

      label = ShortenedLabel.normalize_label(label)
      validate_repo_admin!(context[:current_user], label, level)

      subject_sig = SubjectSig.find_by(id: id)
      raise GraphQL::ExecutionError.new I18n.t('subject_access_level.not_found') if subject_sig.nil?
      subject_ref = SubjectRef.find_by(id: subject_sig.subject_ref_id)
      raise GraphQL::ExecutionError.new I18n.t('subject_access_level.not_found') if subject_ref.nil?
      target_sig_subject = Subject.find_by(label: link_sig_label, level: "community")
      raise GraphQL::ExecutionError.new I18n.t('subject_sig.invalid_link_sig_label') if target_sig_subject.nil?


      ActiveRecord::Base.transaction do
        subject_sig.update!(
          {
            name: name,
            description: description,
            maintainers: maintainers.any? ? maintainers.to_json : nil,
            emails: maintainers.any? ? emails.to_json : nil
          }
        )
        if subject_ref.child_id != target_sig_subject.id
          subject_ref.update!(child_id: target_sig_subject.id)
        end
      end

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
