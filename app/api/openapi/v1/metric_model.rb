# frozen_string_literal: true

module Openapi
  module V1
    class MetricModel < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      resource :metric_model do
        desc 'Metric models overview'
        params do
          requires :label, type: String, desc: 'repo or community label'
          optional :level, type: String, desc: 'level (repo/community), default: repo'
          optional :repo_type, type: String, desc: 'repo type, for repo level default: null and community level default: software-artifact'
        end
        get :overview do
          label = params[:label]
          level = params[:level] || 'repo'
          repo_type = params[:repo_type]
          label = ShortenedLabel.normalize_label(label)
          level = label =~ URI::regexp ? 'repo' : 'community' if label
          MetricModelsServer.new(label: label, level: level, repo_type: repo_type).overview
        end
      end
    end
  end
end
