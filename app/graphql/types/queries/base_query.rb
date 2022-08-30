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

      def extract_date(range)
        now = Date.today

        end_date = Date.today

        interval = '7d'

        begin_date =
          case range.to_s.downcase
          when '3m'
            interval = false
            now - 3.months
          when '6m'
            interval = false
            now - 6.months
          when '1y'
            interval = '1M'
            now - 1.year
          when '2y'
            interval = '1M'
            now - 2.years
          when '3y'
            interval = '1q'
            now - 3.years
          when '5y'
            interval = '1q'
            now - 5.years
          when '10y'
            interval = '1q'
            now - 10.years
          else
            interval = '1q'
            Date.new(2000)
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
            if template.present? && data.present?
              skeletons << builder.(skeleton, {template: template, data: data})
            end
          end
        else
          hits.map do |data|
            data = data['_source']
            skeleton = Hash[base_type.fields.keys.zip([])].symbolize_keys
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
