# frozen_string_literal: true

module Types
  module Queries
    class BetaMetricOverviewQuery < BaseQuery
      type BetaMetricOverviewType, null: false
      description 'return beta metric overview'
      argument :id, Integer, required: true, description: 'beta metric id'
      argument :limit, Integer, required: false, description: 'bete metric repository number'
      def resolve(id: nil, limit: 10)
        skeleton = Hash[Types::BetaMetricOverviewType.fields.keys.zip([])].symbolize_keys
        beta_metric = BetaMetric.find_by(id: id)
        result =
          if beta_metric
            metric = beta_metric.op_metric.constantize
            skeleton['projects_count'] = aggs_distinct(metric, :label)
            candidate_set =
              metric
                .custom(collapse: { field: 'label.keyword' })
                .page(1)
                .per(limit)
                .sort(beta_metric.op_index => :desc)
                .source(['label'])
                .execute
                .raw_response['hits']['hits'].map{ |row| row['_source']['label'] }
            gitee_repos = candidate_set.select { |row| row =~ /gitee\.com/ }
            github_repos = candidate_set.select { |row| row =~ /github\.com/ }
            resp = GithubRepo.only(github_repos)
            resp2 = GiteeRepo.only(gitee_repos)
            skeleton['trends'] = build_beta_repo(beta_metric, resp).map { |repo| OpenStruct.new(repo) }
            skeleton['trends'] += build_beta_repo(beta_metric, resp2).map { |repo| OpenStruct.new(repo) }
            skeleton
          else
            skeleton['projects_count'] = 0
            skeleton['trends'] = []
            skeleton
          end
        OpenStruct.new(result)
      end
    end
  end
end
