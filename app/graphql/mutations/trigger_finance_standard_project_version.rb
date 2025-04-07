# frozen_string_literal: true

module Mutations
  class TriggerFinanceStandardProjectVersion < BaseMutation
    field :status, String

    argument :datasets, [Input::ProjectVersionTypeInput], required: true, description: 'the collection of the repositories'

    def resolve(
      datasets: nil
    )
      status = nil
      projects = get_projects(datasets)

      model = LabModel.find_by(id: 298)
      version = LabModelVersion.find_by(id: 358)
      projects.each do |project|
        status = CustomAnalyzeProjectVersionServer.new(user: nil, model: model, version: version, project: project[:label], version_number: project[:version_number], level: 'repo').execute
      end
      status
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.create_failed', reason: ex.message)
    end

    def get_projects(new_datasets)

      filtered_rows = new_datasets.map { |row| row.to_h.merge(label: ShortenedLabel.normalize_label(row.label)) }

      raise ValidateFailed.new(I18n.t('lab_models.invalid_dataset')) if filtered_rows.blank?

      filtered_rows
    end

  end
end
