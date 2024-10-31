# frozen_string_literal: true

module Mutations
  class CreateLabDataset < BaseMutation
    field :data, Types::Lab::DatasetType, null: true

    argument :version_id, Integer, required: true, description: 'lab model version id'
    argument :model_id, Integer, required: true, description: 'lab model  id'
    argument :is_public, Boolean, required: true, description: 'lab model report is public'
    argument :datasets, [Input::DatasetRowTypeInput], required: true, description: 'the collection of the repositories'

    def resolve(
      model_id: nil,
      version_id: nil,
      datasets: nil,
      is_public: nil
    )

      current_user = context[:current_user]
      dataset = nil
      report = nil
      login_required!(current_user)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.datasets_required') unless datasets.present?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      version = LabModelVersion.find_by(id: version_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless version.present?

      unless ::Pundit.policy(current_user, model).execute?
        # fork
        user_id = current_user.id
        query1 = LabModel.where(user_id: user_id, parent_model_id: model_id)
        if model.parent_model_id.present?
          query2 = LabModel.where(user_id: user_id, parent_model_id: model.parent_model_id)
          exist_model = query1.or(query2).first
        else
          exist_model = query1.first
        end

        ActiveRecord::Base.transaction do
          if exist_model.present?
            exist_version = LabModelVersion.find_by(lab_model_id: exist_model.id, parent_lab_model_version_id: version_id)
            if exist_version.present?
              exist_report = LabModelReport.find_by(lab_model_id: exist_model.id, lab_model_version_id: exist_version.id)
              exist_dateset = LabDataset.find_by(id: exist_report.lab_dataset_id)
              update_dataset = merge_dataset(exist_dateset.content, datasets)
              exist_dateset.update!({ content: update_dataset })
              exist_report.update!(is_public: is_public)

              report = exist_report
              model = exist_model
              version = exist_version
            else
              # create a new version
              version = exist_model.versions.create!(algorithm: version.algorithm, lab_dataset_id: 0, is_score: version.is_score)
              metrics = version.metrics
              LabModelMetric.create_by_version(version, metrics)
              report = LabModelReport.create!(lab_model_id: exist_model.id, lab_model_version_id: version.id, user_id: current_user.id, is_public: is_public)
              dataset = LabDataset.create_report_and_validate!(version, datasets, report)
              version.update!({ lab_dataset_id: dataset.id })
              report.update!({ lab_dataset_id: dataset.id })
            end

          else
            # create a new model, new version
            model =
              current_user.lab_models.create!(
                {
                  name: model.name,
                  dimension: 0,
                  description: model.description,
                  is_public: false,
                  is_general: true,
                  parent_model_id: model.id
                }
              )
            metrics = version.metrics
            version = model.versions.create!(algorithm: version.algorithm, lab_dataset_id: 0, is_score: version.is_score, parent_lab_model_version_id: version_id)
            model.members.create!(user: current_user, permission: LabModelMember::All)
            LabModelMetric.create_by_version(version, metrics)
            report = LabModelReport.create!(lab_model_id: model.id, lab_model_version_id: version.id, user_id: current_user.id, is_public: is_public)
            dataset = LabDataset.create_report_and_validate!(version, datasets, report)
            version.update!({ lab_dataset_id: dataset.id })
            report.update!({ lab_dataset_id: dataset.id })
          end
        end
      end

      # update or create
      report = LabModelReport.find_by(lab_model_id: model_id, lab_model_version_id: version_id)
      if report.present?
        # update dataset
        exist_dataset = LabDataset.find_by(id: report.lab_dataset_id)
        update_dataset = merge_dataset(exist_dataset.content, datasets)
        exist_dataset.update!(content: update_dataset)
        report.update!(is_public: is_public)
      else
        report = LabModelReport.create!(lab_model_id: model.id, lab_model_version_id: version.id, user_id: current_user.id)
        dataset = LabDataset.create_report_and_validate!(version, datasets, report)
        version.update!({ lab_dataset_id: dataset.id })
        report.update!({ lab_dataset_id: dataset.id })
      end

      CustomAnalyzeReportServer.new({ user: current_user, model: model, version: version, report: report }).execute

      { data: dataset }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.create_failed', reason: ex.message)
    end

    def merge_dataset(existing_content, new_datasets)

      existing_content = JSON.parse(existing_content)
      existing_hash = existing_content.each_with_object({}) do |item, hash|
        hash[item["label"]] = item
      end
      new_datasets.each do |dataset|
        existing_hash[dataset.label] ||= {
          label: dataset.label,
          level: dataset.level,
          first_ident: dataset.first_ident,
          second_ident: dataset.second_ident
        }
      end

      existing_hash.values.to_json
    end

  end
end
