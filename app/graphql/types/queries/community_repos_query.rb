# frozen_string_literal: true

module Types
  module Queries
    class CommunityReposQuery < BaseQuery
      include Pagy::Backend

      type Types::Meta::RepoPageType, null: false
      description 'Get repos list of a community'
      argument :label, String, required: true, description: 'community label'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'
      argument :type, String, required: false, description: 'filter by community repository type'

      def resolve(label: nil, page: 1, per: 9, type: nil)
        subject = Subject.find_by(label: label, level: 'community')
        raise GraphQL::ExecutionError.new I18n.t('subjects.not_found') unless subject.present?
        repos =
          case type
          when Director::ARTIFACT_TYPE
            subject.software_repos
          when Director::GOVERNANCE_TYPE
            subject.governance_repos
          else
            subject.repos
          end
        pagyer, records = pagy(repos, { page: page, items: per })
        { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records}
      end
    end
  end
end
