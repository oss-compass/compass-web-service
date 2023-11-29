# frozen_string_literal: true

module Types
  module Queries
    class RepoBelongsToQuery < BaseQuery
      type [ProjectCompletionRowType], null: false
      description 'Search for community where specifical repos are included'
      argument :label, String, required: true, description: 'repo label (repo url)'
      argument :level, String, required: false, description: 'level (repo/community), default: repo'

      def resolve(label: nil, level: 'repo')
        label = ShortenedLabel.normalize_label(label)
        subject = Subject.find_by(label: label, level: level)
        return [] unless subject.present?
        subject.parents.map(&:to_project_row)
      end
    end
  end
end
