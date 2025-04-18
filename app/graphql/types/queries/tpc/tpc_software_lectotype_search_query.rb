# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareLectotypeSearchQuery < BaseQuery
        include Pagy::Backend

        type [Types::Tpc::TpcSoftwareLectotypeSearchType], null: true
        description 'Get tpc software lectotype search'
        argument :label, String, required: false, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or project level(repo/community)'
        # argument :selection_type, Integer, required: true, description: 'incubation: 0'
        argument :keyword, String, required: true, description: 'search word'

        def resolve(label: nil, level: nil, keyword: nil)
          subject = Subject.find_by(label: label, level: level)

          items = []
          if subject.present?
            latest_record_ids = TpcSoftwareLectotype.select("max(id) as id")
                                                    .where(subject_id: subject.id)
                                                    .where("target_software LIKE ?", "%#{keyword}%")
                                                    .group(:target_software)
                                                    .limit(5)
            ids = latest_record_ids.map do |item|
              item["id"]
            end
            items = TpcSoftwareLectotype.where(id: ids)
          end
          items
        end
      end
    end
  end
end
