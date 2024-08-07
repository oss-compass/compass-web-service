# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSelectionSearchQuery < BaseQuery
        include Pagy::Backend

        type [Types::Tpc::TpcSoftwareSelectionSearchType], null: true
        description 'Get tpc software selection search'
        argument :label, String, required: false, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or project level(repo/community)'
        argument :selection_type, Integer, required: true, description: 'incubation: 0'
        argument :keyword, String, required: true, description: 'search word'

        def resolve(label: nil, level: nil, selection_type: 0, keyword: nil)
          subject = Subject.find_by(label: label, level: level)

          items = []
          if subject.present?
            latest_record_ids = TpcSoftwareSelection.select("max(id) as id")
                                                    .where(selection_type: selection_type)
                                                    .where(subject_id: subject.id)
                                                    .where("target_software LIKE ?", "%#{keyword}%")
                                                    .group(:target_software)
                                                    .limit(5)
            ids = latest_record_ids.map do |item|
              item["id"]
            end
            items = TpcSoftwareSelection.where(id: ids)
          end
          items
        end
      end
    end
  end
end
