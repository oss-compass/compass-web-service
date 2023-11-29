module Openapi
  module V1
    class Subject < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      resource :subject do
        desc 'Search for belongs_to where specific subject are included'
        params do
          requires :label, type: String, desc: 'repo/community label (repo url)'
          optional :level, type: String, desc: 'level (repo/community), default: repo'
        end
        get :belongs_to do
          label = params[:label]
          level = params[:level] || 'repo'
          label = ShortenedLabel.normalize_label(label)
          subject = ::Subject.find_by(label: label, level: level)
          return [] unless subject.present?
          subject.parents.map(&:to_project_row)
        end
      end
    end
  end
end
