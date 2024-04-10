# frozen_string_literal: true

module Types
  module Queries
    class CollectionListQuery < BaseQuery

      type Types::Collection::CollectionPageType, null: false
      description 'Get collection list by a ident'
      argument :ident, String, required: true, description: 'collection ident'
      argument :level, String, required: false, description: 'filter by level, default: all'
      argument :page, Integer, required: false, description: 'page number, default: 1'
      argument :per, Integer, required: false, description: 'per page number, default: 20'
      argument :keyword, String, required: false, description: 'search repositories with keywords'
      argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'

      def resolve(ident:, level: nil, page: 1, per: 20, keyword: nil, sort_opts: [])
        resp = BaseCollection.list(ident, level, page, per, keyword, sort_opts)
        count = BaseCollection.count_by(ident, level, keyword)
        labels = resp&.[]('hits')&.[]('hits')&.map{ |item| item['_source']['label'] }
        candidates = []
        if labels.present?
          gitee_repos = labels.select {|row| row =~ /gitee\.com/ }
          github_repos = labels.select {|row| row =~ /github\.com/ }
          resp = GithubRepo.only(github_repos)
          resp2 = GiteeRepo.only(gitee_repos)
          candidates = build_github_repo(resp).map { |repo| OpenStruct.new(repo) }
          candidates += build_gitee_repo(resp2).map { |repo| OpenStruct.new(repo) }
        else
          []
        end
        { count: count, total_page: (count.to_f/per).ceil, page: page, items: candidates }
      end
    end
  end
end
