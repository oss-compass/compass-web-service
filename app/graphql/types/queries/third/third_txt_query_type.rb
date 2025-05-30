# frozen_string_literal: true

module Types
  module Queries
    module Third

      class ThirdTxtQueryItemType < Types::BaseObject
        field :keywords_bm25_score, Float
        field :keywords_embedding_score, Float
        field :package_id, String
        field :score, Float
        field :summary_bm25_score, Float
        field :summary_embedding_score, Float
        field :label, String


        def normalize_repo_url(repo_url)
          return nil if repo_url.blank?

          # 只取第一个（用 ; 或空格等分隔）
          first_url = repo_url.split(/[;\s]/).first.to_s.strip
          return nil if first_url.blank?

          # 将 git@github.com:org/repo.git 转成 https://github.com/org/repo
          if first_url =~ %r{\Agit@github\.com:(.+?)(\.git)?\z}
            "https://github.com/#{$1}"
          else
            # 如果已经是 https 或其它形式则直接返回
            first_url
          end
        end

        def label

          package = object["package_id"] || object[:package_id]
          # Rails.logger.debug "data[:package_id]: #{package}"
          return nil if package.blank?

          package_detail = MongoIndex.query_by_package_id(package)

          namespace_name, source_part = package.split('@@@@$$@@@@')
          source = source_part.to_s.sub('selected.', '') # "github", "gitee", "npm"
          return nil if namespace_name.blank? || source.blank?

          source = source_part.sub('selected.', '') # 如 github/gitee/npm
          project_url =  package_detail["repo_url"].presence || package_detail["lib_url"].presence

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
              return  project_url
            end
              return "https://www.npmjs.com/package/#{namespace_name}"
          else
            project_url
          end
        end
      end

      class ThirdTxtQueryType < Types::BaseObject
        field :items, [ThirdTxtQueryItemType]
      end

    end
  end
end
