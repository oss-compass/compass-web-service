# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class FinanceStandardProjectVersionStatusQuery < BaseQuery

        type Types::Lab::ProjectVersionModelsStatusType, null: true
        description 'Get project trigger status'
        argument :label, String, required: true, description: 'project url'
        argument :version_number, String, required: true, description: 'project url'

        def resolve(label: nil, version_number: nil)
          model = LabModel.find_by(id: 298)
          version = LabModelVersion.find_by(id: 358)
          status = CustomAnalyzeProjectVersionServer.new(user: nil, model: model, version: version, project: label, version_number: version_number, level: 'repo').check_task_status
          { trigger_status: status }
        end
      end
    end
  end
end

