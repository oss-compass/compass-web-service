module Types
  module Queries
    class BaseQuery < GraphQL::Schema::Resolver
      include Director
      include CompassUtils

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

      def validate_by_label!(current_user, label)
        if RESTRICTED_LABEL_LIST.include?(label) && !RESTRICTED_LABEL_VIEWERS.include?(current_user&.id.to_s)
          raise GraphQL::ExecutionError.new I18n.t('users.forbidden')
        end
      end

      def login_required!(current_user)
        raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?
      end

      def validate_date!(current_user, label, level, begin_date, end_date)
        login_required!(current_user)
        diff_seconds = end_date.to_i - begin_date.to_i
        return if diff_seconds < 2.months
        origin = extract_repos_source(label, level)
        username = LoginBind.current_host_nickname(current_user, origin)
        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)
        unless indexer.repo_admin?(username, repo_urls)
          raise GraphQL::ExecutionError.new I18n.t('basic.invalid_range', param: '`begin_date` or `end_date`', min: Date.today - 1.month, max: Date.today)
        end
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
          JSON.parse(project.extra)['community_org_url'] rescue nil
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

      def extract_logo_url(label)
        if label =~ /github\.com\/(.+)\/(.+)/
          "https://github.com/#{$1}.png"
        elsif label =~ /gitee\.com\/(.+)\/(.+)/
          "https://gitee.com/#{$1}.png"
        else
          JSON.parse(ProjectTask.find_by(project_name: label).extra)['community_logo_url'] rescue nil
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

      def select_idx_repos_by_lablel_and_level(label, level, gitee_idx, github_idx)
        if level == 'repo' && label =~ /gitee\.com/
          [gitee_idx, [label], 'gitee']
        elsif level == 'repo'&& label =~ /github\.com/
          [github_idx, [label], 'github']
        else
          project = ProjectTask.find_by(project_name: label)
          repo_list = director_repo_list(project&.remote_url)
          origin = extract_repos_source(label, level)
          [origin == 'gitee' ? gitee_idx : github_idx, repo_list, origin]
        end
      end

      def distribute_by_field(base_indexer, field, total_count = nil)
        resp =
          base_indexer
            .aggregate({ distribution: { terms: { field: field } } })
            .per(0)
            .execute
            .aggregations
            .dig('distribution', 'buckets')

        if total_count.nil?
          total_count = resp.reduce(0) { |acc, bucket| acc += bucket['doc_count'] }
        end

        resp
          .map do |bucket|
            {
              sub_count: bucket['doc_count'],
              sub_ratio: total_count == 0 ? 0 : (bucket['doc_count'].to_f / total_count.to_f),
              sub_name: bucket['key'],
              total_count: total_count
            }
        end
      end

      def filter_by_origin(list, origin, remove_suffix: true)
        list
          .select { |row| row =~ origin }
          .map { |row| remove_suffix ? row.sub(/\.git/, '') : row }
      end

      def build_report_data(label, model, version, resp)
        hits = resp&.fetch('hits', {})&.fetch('hits', [])
        metric_with_fields = version.metrics.reduce({}) do |acc, metric|
          acc.merge(metric => metric.extra_fields)
        end
        fields_key = metric_with_fields.values.flatten
        fields_set = fields_key.to_h { |m| [m, []] }
        dates = []
        scores = []
        panels = []
        hits.each do |hit|
          data = hit['_source']
          dates << data['grimoire_creation_date']
          scores << data['score']
          fields_key.each do |key|
            fields_set[key] << data[key]
          end
        end

        metric_with_fields.each do |metric, fields|
          diagrams = fields.map { |field| { tab_ident: field, type: metrics_graph_mapping(field), dates: dates, values: fields_set[field] } }
          panels << {
            metric: metric,
            diagrams: diagrams
          }
        end

        {
          label: label,
          level: 'repo',
          short_code: ShortenedLabel.convert(label, 'repo'),
          type: nil,
          main_score: { tab_ident: 'score', type: 'line', dates: dates, values: scores },
          panels: panels,
        }
      end

      def build_simple_report_data(aggs)
        reports = aggs&.fetch('reports', {})&.fetch('buckets', [])
        skeletons = []
        reports.each do |report|
          hits = report.fetch('docs', {})&.fetch('hits', [])
          values = []
          dates = []
          hits.each do |hit|
            dates << hit['_source']['grimoire_creation_date']
            values << hit['_source']['score']
          end
          skeletons << {
            label: report['key'],
            level: 'repo',
            short_code: ShortenedLabel.convert(report['key'], 'repo'),
            type: nil,
            main_score: { tab_ident: 'score', type: 'line', dates: dates, values: values }
          }
        end
        skeletons
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

      def metrics_graph_mapping(field)
        case field
        when 'lines_of_code_frequency', 'lines_add_of_code_frequency','lines_remove_of_code_frequency'
          'bar'
        else
          'line'
        end
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
