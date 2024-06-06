# frozen_string_literal: true

module Types
  module Queries
      class SubjectAccessLevelPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Meta::SubjectAccessLevelPageType, null: true
        description 'Get detail data of my lab models'
        argument :label, String, required: true, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'
        argument :access_level, Integer, required: false, description: 'NORMAL/COMMITTER: 0, PRIVILEGED/LEADER: 1, default: nil'

        def resolve(label: nil, level: 'repo', page: 1, per: 9, access_level: nil)
          current_user = context[:current_user]
          login_required!(current_user)
          validate_by_label!(current_user, label)

          subject = Subject.find_by(label: label, level: level)
          raise GraphQL::ExecutionError.new I18n.t('subject_access_level.invalid_label') unless subject

          if access_level.nil?
            items = subject.subject_access_levels
          else
            items = subject.subject_access_levels.where(access_level: access_level)
          end
          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
  end
end
