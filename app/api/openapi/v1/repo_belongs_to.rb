module Openapi
  module V1
    class RepoBelongsTo < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      resource :repo_belongs_to do
        desc 'Search for community where specific repos are included'
        params do
          requires :label, type: String, desc: 'repo label (repo url)'
          optional :level, type: String, desc: 'level (repo/community), default: repo'
        end
        get do
          label = params[:label]
          level = params[:level] || 'repo'
          label = ShortenedLabel.normalize_label(label)
          subject = Subject.find_by(label: label, level: level)
          return [] unless subject.present?
          subject.parents.map(&:to_project_row)
        end
      end
    end
  end
end
