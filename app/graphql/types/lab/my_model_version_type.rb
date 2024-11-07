# frozen_string_literal: true

module Types
  module Lab
    class MyModelVersionType < Types::BaseObject
      field :id, Integer, null: false
      field :version_id, Integer, null: false
      field :model_id, Integer, null: false
      field :report_id, Integer, null: false
      field :parent_model_id, Integer
      field :is_public, Boolean

      field :version, String
      field :model_name, String
      field :trigger_status, String
      field :trigger_updated_at, GraphQL::Types::ISO8601DateTime
      field :dataset, DatasetType
      field :dataset_status, DatasetStatusType
      field :metrics, [ModelMetricType], null: true
      field :algorithm, AlgorithmType
      field :parent_lab_model, ModelDetailType

      def parent_lab_model
        LabModel.find_by(id: model.parent_model_id)
      end

      def dataset_status
        dataset = model.dataset
        return nil unless dataset
        {
          name: dataset.name,
          ident: dataset.ident,
          items: build_items(dataset)
        }
      end

      def build_items(dataset)
        dataset.items.map do |item|
          {
            label: item["label"],
            level: item["level"],
            short_code: item["short_code"],
            first_ident: item["first_ident"],
            second_ident: item["second_ident"],
            trigger_status: fetch_trigger_status(model.model_id, model.version_id, item["label"]),
            trigger_updated_at: fetch_trigger_updated_at(model.model_id, model.version_id, item["label"]),
            logo_url: extract_logo_url(item["label"])
          }
        end
      end

      def fetch_trigger_status(model_id, version_id, project_url)
        CustomAnalyzeProjectServer.new({ user: nil, model: LabModel.find_by(id: model_id), version: LabModelVersion.find_by(id: version_id), project: project_url }).check_task_status
      end

      def fetch_trigger_updated_at(model_id, version_id, project_url)
        CustomAnalyzeProjectServer.new({ user: nil, model: LabModel.find_by(id: model_id), version: LabModelVersion.find_by(id: version_id), project: project_url }).check_task_updated_time
      end

      def extract_logo_url(label)
        if label =~ /github\.com\/(.+)\/(.+)/
          "https://github.com/#{$1}.png"
        elsif label =~ /gitee\.com\/(.+)\/(.+)/
          "https://gitee.com/#{$1}.png"
        else
          JSON.parse(ProjectTask.find_by(project_name: label).extra)['community_logo_url'] rescue nil
        end
      end

      def model
        @model ||= object
      end
    end
  end
end
