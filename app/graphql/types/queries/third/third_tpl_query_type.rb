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
          Rails.logger.debug "data[:package_id]: #{package}"
          return nil if package.blank?

          namespace_name, source_part = package.split('@@@@$$@@@@')
          source = source_part.to_s.sub('selected.', '') # "github", "gitee", "npm"
          return nil if namespace_name.blank? || source.blank?

          source = source_part.sub('selected.', '') # 如 github/gitee/npm

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
            if namespace_name.start_with?('@')
              # 作用域包，保留 @
              "https://www.npmjs.com/package/#{namespace_name}"
            else
              # 普通包
              "https://www.npmjs.com/package/#{namespace_name}"
            end
          else
            nil
          end
        end
      end

      class ThirdTplQueryType < Types::BaseObject
        field :items, [ThirdTplQueryItemType]
      end

    end
  end
end
