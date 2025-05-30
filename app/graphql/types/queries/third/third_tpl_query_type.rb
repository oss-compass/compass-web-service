# frozen_string_literal: true

module Types
  module Queries
    module Third

      class ThirdTplQueryItemType < Types::BaseObject
        field :package_id, String
        field :score, Float
        field :raw_search_score, Float
        field :keywords_bm25_score, Float
        field :keywords_embedding_score, Float
        field :summary_bm25_score, Float
        field :summary_embedding_score, Float
        field :vote_up, [String]
        field :vote_down, [String]
        field :label, String

        def label

          package = object["package_id"] || object[:package_id]
          # Rails.logger.debug "data[:package_id]: #{package}"
          return nil if package.blank?

          package_detail = MongoIndex.query_by_package_id(package)

          namespace_name, source_part = package.split('@@@@$$@@@@')
          source = source_part.to_s.sub('selected.', '')
          return nil if namespace_name.blank? || source.blank?

          source = source_part.sub('selected.', '')
          project_url = package_detail["repo_url"].presence || package_detail["lib_url"].presence

          case source
          when 'github'
            parts = namespace_name.split('/')
            return '' unless parts.size == 2
            "https://github.com/#{parts[0]}/#{parts[1]}"
          when 'gitee'
            parts = namespace_name.split('/')
            return '' unless parts.size == 2
            "https://gitee.com/#{parts[0]}/#{parts[1]}"
          when 'npm'
            if project_url.present?
              return project_url
            end
            return "https://www.npmjs.com/package/#{namespace_name}"
          else
            project_url
          end
        end
      end

      class ThirdTplQueryType < Types::BaseObject
        field :items, [ThirdTplQueryItemType]
      end

    end
  end
end
