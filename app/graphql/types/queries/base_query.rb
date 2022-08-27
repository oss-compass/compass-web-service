module Types
  module Queries
    class BaseQuery < GraphQL::Schema::Resolver
      # methods that should be inherited can go here.
      # like a `current_tenant` method, or methods related
      # to the `context` object
      def build_github_repo(resp)
        hits = resp&.[]('hits')&.[]('hits')
        skeletons = []
        if hits.present?
          hits.map do |data|
            data = data['_source']
            skeleton = Hash[Types::RepoType.fields.keys.zip([])].symbolize_keys
            if data.present?
              skeleton['origin'] = data['origin']
              skeleton['name'] = data['data']['name']
              skeleton['language'] = data['data']['language']
              skeleton['path'] = data['data']['full_name']
              skeleton['backend'] = data['backend_name']
              skeleton['pulls_count'] = (GithubPull.must(match: { origin: data['origin'] }).total_entries rescue 0)
              skeleton['issues_count'] = (GithubIssue.must(match: { origin: data['origin'] }).total_entries rescue 0)
              skeleton['forks_count'] = data['data']['forks_count']
              skeleton['watchers_count'] = data['data']['subscribers_count']
              skeleton['stargazers_count'] = data['data']['stargazers_count']
              skeleton['open_issues_count'] = data['data']['open_issues_count']
              skeleton['created_at'] = data['data']['created_at']
              skeleton['updated_at'] = data['data']['updated_at']
            end
            skeletons << skeleton
          end
        end
        skeletons
      end

      def build_metrics_data(resp, base_type, &builder)
        hits = resp&.[]('hits')&.[]('hits')
        skeletons = []
        hits.map do |data|
          data = data['_source']
          skeleton = Hash[base_type.fields.keys.zip([])].symbolize_keys
          if data.present?
            skeletons << builder.(skeleton, data)
          end
        end
        skeletons
      end
    end
  end
end
