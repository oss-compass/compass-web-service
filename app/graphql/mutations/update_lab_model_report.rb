# frozen_string_literal: true

module Mutations
  class UpdateLabModelReport < BaseMutation

    field :data, Types::Lab::ModelReportType, null: true

    argument :report_id, Integer, required: true, description: 'report id'
    argument :datasets, [Input::DatasetRowTypeInput], required: false, description: 'the collection of the repositories'
    argument :is_public, Boolean, required: false, description: 'whether or not a public model, default: false'

    def resolve(
      report_id: nil,
      datasets: nil,
      is_public: nil
    )

      current_user = context[:current_user]

      login_required!(current_user)

      report = LabModelReport.find_by(id: report_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless report.present?
      ActiveRecord::Base.transaction do
        update_set = {}
        update_set[:is_public] = is_public if is_public != nil

        report.update!(update_set) if update_set.present?
        report = LabDataset.find_by(lab_model_report_id: report_id)
        if datasets.present?
          filtered_rows =
            datasets
              .map { |row| row.to_h.merge(label: ShortenedLabel.normalize_label(row.label)) }
          content = JSON.dump(filtered_rows)
          report.update!(content: content)
        end
      end
      { data: report }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.update_failed', reason: ex.message)
    end
  end
end
