module Types
  module Queries
    class BaseQuery < GraphQL::Schema::Resolver
      include Director

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
          ActivityMetric.query_repo_by_date(label, Date.today.end_of_day - 90.days, Date.today.end_of_day),
          Types::ActivityMetricType) do |skeleton, raw|
          skeleton.merge!(raw)
          ActivityMetric.fields_aliases.map { |alias_key, key| skeleton[alias_key] = raw[key] }
          OpenStruct.new(skeleton)
        end
      end

      def build_beta_repo_scores(
            beta_metric, label)
        build_metrics_data(
          beta_metric.op_metric.constantize
            .query_repo_by_date(label, Date.today.end_of_day - 90.days, Date.today.end_of_day),
          Types::BetaMetricScoreType) do |score, raw|
          score['name'] = beta_metric.metric
          score['score'] = raw[beta_metric.op_index]
          score['label'] = raw['label']
          score['level'] = raw['level']
          score['short_code'] = ShortenedLabel.convert(raw['label'], raw['level'])
          score['grimoire_creation_date'] = raw['grimoire_creation_date']
          OpenStruct.new(score)
        end
      end

      def build_beta_repo(metric, resp)
        hits = resp&.[]('hits')&.[]('hits')
        skeletons = []
        if hits.present?
          hits.map do |data|
            data = data['_source']
            skeleton = Hash[Types::BetaRepoType.fields.keys.zip([])].symbolize_keys
            if data.present?
              skeleton['origin'] = data['origin']
              skeleton['name'] = data['data']['name']
              skeleton['short_code'] = ShortenedLabel.convert(data['origin'], 'repo')
              skeleton['language'] = data['data']['language']
              skeleton['path'] = data['data']['full_name']
              skeleton['backend'] = data['backend_name']
              skeleton['created_at'] = data['data']['created_at']
              skeleton['updated_at'] = data['data']['updated_at']
              skeleton['beta_metric_scores'] = build_beta_repo_scores(metric, data['origin'])
            end
            skeletons << skeleton
          end
        end
        skeletons
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
              skeleton['short_code'] = ShortenedLabel.convert(data['origin'], 'repo')
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
              skeleton['short_code'] = ShortenedLabel.convert(data['origin'], 'repo')
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
        today = Date.today.end_of_day

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

      def normalize_label(label)
        if label =~ URI::regexp
          uri = Addressable::URI.parse(label)
          "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}"
        else
          label
        end
      end

      def extract_repos_count(label, level)
        if level == 'community'
          project = ProjectTask.find_by(project_name: label)
          project ? director_repo_list(project&.remote_url).length : 1
        else
          1
        end
      end

      def extract_label_reference(label, level)
        if level == 'community'
          project = ProjectTask.find_by(project_name: label)
          JSON.parse(project.extra)['community_url'] rescue nil
        else
          label
        end
      end

      def extract_name_and_full_path(label)
        if label =~ /github\.com\/(.+)\/(.+)/
          [$2, "#{$1}/#{$2}"]
        elsif label =~ /gitee\.com\/(.+)\/(.+)/
          [$2, "#{$1}/#{$2}"]
        else
          [label, label]
        end
      end

      def extract_repos_source(label, level)
        repo_list = [label]
        if level == 'community'
          project = ProjectTask.find_by(project_name: label)
          repo_list = director_repo_list(project&.remote_url)
        end
        github_count, gitee_count = 0,0
        repo_list.each do |url|
          gitee_count += 1 if url =~ /gitee\.com/
          github_count += 1 if url =~ /github\.com/
        end
        if github_count > 0 && gitee_count == 0
          'github'
        elsif gitee_count > 0 && github_count == 0
          'gitee'
        else
          'combine'
        end
      end

      def generate_interval_aggs(base_type, date_field, interval_str='1M', avg_type='Float', aliases={}, suffixs=[])
        metric_fields =
          base_type.fields.select{|k, v| v.type.name.end_with?(avg_type)}.keys.map(&:underscore)
        aggregate_inteval = {
          aggsWithDate: {
            date_histogram: {
              field: date_field,
              calendar_interval: interval_str
            },
            aggs: metric_fields.reduce({}) do |aggs, field|
              if suffixs.present?
                suffixs.reduce(aggs) do |results, suffix|
                  results.merge({ "#{field}#{suffix}" => { avg: { field: "#{aliases[field]}#{suffix}" || "#{field}#{suffix}" } } })
                end
              else
                aggs.merge({ field => { avg: { field: aliases[field] || field } } })
              end
            end
          }
        }
      end

      def filter_by_origin(list, origin, remove_suffix: true)
        list
          .select { |row| row =~ origin }
          .map { |row| remove_suffix ? row.sub(/\.git/, '') : row }
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

      def aggs_distinct(index, field, threshold=100)
        index.aggregate(
          {
            distinct: {
              cardinality: {
                field: field,
                precision_threshold: threshold
              }
            }
          }
        ).per(0).execute.raw_response['aggregations']['distinct']['value']
      rescue
        0
      end

      def aggs_sum(index, field)
        index.aggregate(
          {
            total: {
              sum: {
                field: field
              }
            }
          }
        ).per(0).execute.raw_response['aggregations']['total']['value']
      rescue
        0
      end
    end
  end
end
