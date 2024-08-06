# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSigListQuery < BaseQuery
        type [Types::Tpc::TpcSoftwareSigType], null: true
        description 'Get tpc software sig list'
        argument :label, String, required: false, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or project level(repo/community)'

        def resolve(label: nil, level: nil)
          subject = Subject.find_by(label: label, level: level)
          items = []
          if subject.present?
            items = subject.tpc_software_sigs
          end
          items
        end
      end
    end
  end
end
