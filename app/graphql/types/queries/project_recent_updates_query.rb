# frozen_string_literal: true


module Types
  module Queries
    class ProjectRecentUpdatesQuery < BaseQuery
      type [ProjectCompletionRowType], null: false
      description 'Recent update reports'

      def resolve
        resp = ActivityMetric.recent(10)
        list = resp&.[]('hits')&.[]('hits')
        fields = ['label', 'level']
        candidates = []
        if list.present?
          list.each do |item|
            metadata__enriched_on = item['_source']['metadata__enriched_on']
            updated_at = DateTime.parse(metadata__enriched_on).strftime rescue metadata__enriched_on
            candidates << OpenStruct.new(
              item['_source']
                .slice(*fields)
                .merge(
                  {
                    status: 'success',
                    updated_at: updated_at
                  }
                )
            )
          end
        end

        candidates
      end
    end
  end
end
