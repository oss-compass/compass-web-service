module Types
  module Queries
    class BaseQuery < GraphQL::Schema::Resolver

      SEVEN_DAYS = 7 * 24 * 60 * 60
      HALF_YEAR = 180 * 24 * 60 * 60
      ONE_YEAR = 2 * HALF_YEAR
      TWO_YEARS = 2 * ONE_YEAR
      FIVE_YEARS = 5 * ONE_YEAR
      # methods that should be inherited can go here.
      # like a `current_tenant` method, or methods related
      # to the `context` object

      def build_repo_activity(label)
        build_metrics_data(
          ActivityMetric.query_repo_by_date(label, DateTime.now - 90.days, DateTime.now),
          Types::ActivityMetricType) do |metric, raw|
          metric.merge!(raw)
          metric['active_c1_pr_create_contributor_count'] = raw['active_C1_pr_create_contributor']
          metric['active_c2_contributor_count'] = raw['active_C2_contributor_count']
          metric['active_c1_pr_comments_contributor_count'] = raw['active_C1_pr_comments_contributor']
          metric['active_c1_issue_create_contributor_count'] = raw['active_C1_issue_create_contributor']
          metric['active_c1_issue_comments_contributor_count'] = raw['active_C1_issue_comments_contributor']
          OpenStruct.new(metric)
        end
      end

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
              skeleton['forks_count'] = data['data']['forks_count']
              skeleton['watchers_count'] = data['data']['subscribers_count']
              skeleton['stargazers_count'] = data['data']['stargazers_count']
              skeleton['open_issues_count'] = data['data']['open_issues_count']
              skeleton['created_at'] = data['data']['created_at']
              skeleton['updated_at'] = data['data']['updated_at']
              skeleton['metric_activity'] = build_repo_activity(data['origin'])
            end
            skeletons << skeleton
          end
        end
        skeletons
      end

      def build_gitee_repo(resp)
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
              skeleton['forks_count'] = data['data']['forks_count']
              skeleton['watchers_count'] = data['data']['watchers_count']
              skeleton['stargazers_count'] = data['data']['stargazers_count']
              skeleton['open_issues_count'] = data['data']['open_issues_count']
              skeleton['created_at'] = data['data']['created_at']
              skeleton['updated_at'] = data['data']['updated_at']
              skeleton['metric_activity'] = build_repo_activity(data['origin'])
            end
            skeletons << skeleton
          end
        end
        skeletons
      end

      def extract_date(begin_date, end_date)
        today = DateTime.now

        begin_date = begin_date || today - 3.months
        end_date = [end_date || today, today].min
        diff_seconds = end_date.to_i - begin_date.to_i

        if diff_seconds < SEVEN_DAYS
          begin_date = today - 3.months
          end_date = today
          interval = false
        elsif diff_seconds <= TWO_YEARS
          interval = false
        else
          interval = '1M'
        end
        [begin_date, end_date, interval]
      end

      def generate_interval_aggs(base_type, date_field, interval_str='1M', avg_type='Float', aliases={})
        metric_fields =
          base_type.fields.select{|k, v| v.type.name.end_with?(avg_type)}.keys.map(&:underscore)
        aggregate_inteval = {
          aggsWithDate: {
            date_histogram: {
              field: date_field,
              calendar_interval: interval_str
            },
            aggs: metric_fields.reduce({}) do |aggs, field|
              aggs.merge(
                {
                  field => {
                    avg: {
                      field: aliases[field] || field
                    }
                  }
                }
              )
            end
          }
        }
      end

      def build_metrics_data(resp, base_type, &builder)
        aggs = resp&.[]('aggregations')&.[]('aggsWithDate')&.[]('buckets')
        hits = resp&.[]('hits')&.[]('hits')
        skeletons = []
        if aggs.present?
          template = hits.first&.[]('_source')
          aggs.map do |data|
            skeleton = Hash[base_type.fields.keys.zip([])].symbolize_keys
            skeleton = skeleton.merge(Hash[base_type.fields.keys.map(&:underscore).zip([])].symbolize_keys)
            if template.present? && data.present?
              skeletons << builder.(skeleton, {template: template, data: data})
            end
          end
        else
          hits.map do |data|
            data = data['_source']
            skeleton = Hash[base_type.fields.keys.zip([])].symbolize_keys
            skeleton = skeleton.merge(Hash[base_type.fields.keys.map(&:underscore).zip([])].symbolize_keys)
            if data.present?
              skeletons << builder.(skeleton, data)
            end
          end
        end
        skeletons
      end
    end
  end
end
