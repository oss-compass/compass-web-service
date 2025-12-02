# frozen_string_literal: true

module Openapi
  module V2
    module Star
      class StarProjectServer < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json

        before do
          # require_login!
        end
        # helpers Openapi::SharedParams::ErrorHelpers

        # rescue_from :all do |e|
        #   case e
        #   when Grape::Exceptions::ValidationErrors
        #     handle_validation_error(e)
        #   when SearchFlip::ResponseError
        #     handle_open_search_error(e)
        #   when Openapi::Entities::InvalidVersionNumberError
        #     handle_release_error(e)
        #   else
        #     handle_generic_error(e)
        #   end
        # end

        helpers do
          include Pagy::Backend

          def paginate_fun(scope)
            pagy(scope, page: params[:page], items: params[:per_page])
          end

          def get_index_data_scroll(base_indexer, urls, field, begin_date, end_date, batch_size = 1000)
            all_hits = []

            query = base_indexer
                      .must(terms: { 'label.keyword' => urls })
                      .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                      .sort(grimoire_creation_date: :asc)
                      .source(field)

            query.find_results_in_batches(batch_size: batch_size) do |batch|
              batch.each do |source|
                if field.is_a?(Array)
                  entry = {}
                  field.each do |f|
                    entry[f.to_sym] = source[f.to_s]
                  end
                else
                  entry = { field.to_sym => source[field.to_s] }
                end
                all_hits << entry
              end
            end

            all_hits
          end

          def get_index_last_data_scroll(base_indexer, urls, field, begin_date, end_date)
            all_hits = []
            batch_size = 1000
            # 构建 Scroll 查询
            query = base_indexer
                      .must(terms: { 'label.keyword' => urls })
                      .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                      .sort(grimoire_creation_date: :asc) # asc 方便最后取每组最后一条
                      .source(field)

            # Scroll 获取所有数据
            query.find_results_in_batches(batch_size: batch_size) do |batch|
              batch.each do |source|
                entry = { label: source["label"] }

                if field.is_a?(Array)
                  field.each do |f|
                    next if f.to_s == "label"
                    entry[f.to_sym] = source[f.to_s]
                  end
                else
                  key = field.to_s
                  entry[key.to_sym] = source[key] unless key == "label"
                end

                # 追加
                all_hits << entry
              end
            end

            # 按 label 分组，每组取最后一条（因为 asc 排序 → 最新在最后）
            latest_hits = all_hits.group_by { |e| e[:label] }.map do |label, items|
              items.last
            end

            latest_hits
          end

          def get_community_name(keyword)
            fields = ['label', 'level']
            level = nil
            es_filters = { level: level }

            candidates = []
            existed_labels = {}

            # === fuzzy / prefix 搜索统一处理 ===
            searches = [
              ActivityMetric.fuzzy_search(keyword.gsub('/', ' '), 'label', 'label.keyword', fields: fields, filters: es_filters)&.dig('hits', 'hits'),
              ActivityMetric.prefix_search(keyword, 'label.keyword', 'label.keyword', fields: fields, filters: es_filters)&.dig('hits', 'hits')
            ]

            searches.each do |list|
              next unless list.present?

              list.each do |item|
                inner_hits = item.dig('inner_hits', 'by_level', 'hits', 'hits') || []
                inner_hits.each do |hit|
                  src = hit['_source'] || {}
                  label = src['label']
                  next if existed_labels[label]

                  metadata_enriched_on = src['metadata__enriched_on']
                  updated_at = begin
                                 DateTime.parse(metadata_enriched_on).strftime
                               rescue
                                 metadata_enriched_on
                               end

                  candidate = {
                    label: label,
                    level: src['level'],
                    status: ProjectTask::Success,
                    updated_at: updated_at,
                    short_code: ShortenedLabel.convert(label, src['level']),
                    collections: BaseCollection.collections_of(label, level: src['level'])
                  }

                  candidates << candidate
                  existed_labels[label] = true
                end
              end
            end

            # === ProjectTask 查询补充 ===
            tasks = ProjectTask.where('project_name LIKE ?', "%#{keyword}")
                               .yield_self { |query| level.present? ? query.where(level: level) : query }
                               .limit(5)

            tasks.each do |item|
              next if existed_labels[item.project_name]

              candidate = {
                label: item.project_name,
                level: item.level,
                status: item.status,
                updated_at: item.updated_at,
                short_code: ShortenedLabel.convert(item.project_name, item.level),
                collections: BaseCollection.collections_of(item.project_name, level: item.level)
              }

              candidates << candidate
              existed_labels[item.project_name] = true
            end

            candidates
          end

        end

        resource :start_project_server do

          desc '获取表格的项目列表', hidden: true, tags: ['starProject'], success: {
            code: 201
          }, detail: ''
          params do
            optional :project_urls, type: String, desc: '项目地址', documentation: { param_type: 'body' }
            optional :type, type: Integer, desc: '类型，0普通队列，1优先队列', documentation: { param_type: 'body' }
          end
          post :project_list do
            # 获取表格的项目列表
            puts " 获取表格的项目列表"
            project = params[:project_urls]

            get_community_name(project)

          end

          desc '获取开源参与人数', hidden: true, tags: ['starProject'], success: {
            code: 201
          }, detail: ''
          params do
            requires :project_urls, type: Array[String], desc: '项目地址', documentation: { param_type: 'body' }
            requires :company, type: String, desc: '公司名称', documentation: { param_type: 'body' }

          end
          post :participant_count do

            urls = params[:project_urls]
            company = params[:company]

            per_project_results = []
            all_company_ids = []

            urls.each do |multi_url|
              #   拆分用户传来的多 URL ---
              split_urls = multi_url.split(/,|;|\s+/)
                                    .map(&:strip)
                                    .reject(&:empty?)

              #   找到所有匹配的 star_project ---
              project_ids = StarProject.where(repo_url: split_urls).pluck(:id)

              # 如果一个都找不到，项目贡献人数为 0
              if project_ids.empty?
                per_project_results << {
                  project_url: multi_url,
                  participant_company_count: 0
                }
                next
              end

              #  查询所有 project_id 的参与者 ---
              raw_company_ids = StarProjectParticipant
                                  .where(star_project_id: project_ids)
                                  .pluck(:participant_company_id)

              #   处理参与者公司 ID ---
              project_company_ids = raw_company_ids.flat_map do |cid|
                next [] if cid.nil? || cid.strip.empty?

                cid.split(/;|,|\s+/)
                   .map(&:strip)
                   .reject(&:empty?)
              end

              unique_company_ids = project_company_ids.uniq

              #  按“用户传入的合并 URL”输出 ---
              per_project_results << {
                project_url: multi_url, # 保持原始形式
                participant_company_count: unique_company_ids.size
              }

              all_company_ids.concat(unique_company_ids)
            end

            total_unique_company = all_company_ids.uniq.size

            {
              code: 201,
              project_stats: per_project_results,
              total_unique_participants_by_company: total_unique_company
            }

          end

          desc '获取star数', hidden: true, tags: ['starProject'], success: {
            code: 201
          }, detail: ''
          params do
            requires :project_urls, type: Array[String], desc: '项目地址', documentation: { param_type: 'body' }

          end
          post :star_count do

            #  如果是社区的 需要去查询 出来 项目地址

            # 获取star数
            github_urls = params[:project_urls].select { |u| u.include?('github.com') }
            gitee_urls = params[:project_urls].select { |u| u.include?('gitee.com') }
            gitcode_urls = params[:project_urls].select { |u| u.include?('gitcode.com') }
            unique_urls = params[:project_urls].uniq
            results = []

            [
              { index: GithubRepoEnrich, urls: github_urls },
              { index: GitcodeRepoEnrich, urls: gitcode_urls },
              { index: GiteeRepoEnrich, urls: gitee_urls }
            ].each do |group|
              next if group[:urls].empty?

              target = 'tag.keyword'

              res = group[:index]
                      .must(terms: { target => group[:urls] })
                      .sort(grimoire_creation_date: :desc)
                      .source(['tag', 'stargazers_count'])
                      .execute
                      .raw_response

              hits = res.dig('hits', 'hits')&.map do |hit|
                src = hit['_source']
                {
                  repo_url: src['tag'],
                  star_count: src['stargazers_count']
                }
              end || []

              # 同一个项目只保留最新一条
              latest_hits = hits.uniq { |h| h[:repo_url] }

              results.concat(latest_hits)
            end

            # 没找到的补上
            existing_urls = results.map { |r| r[:repo_url] }
            missing_urls = unique_urls - existing_urls
            missing_urls.each do |url|
              results << { repo_url: url, star_count: nil }
            end

            { code: 201, data: results }
          end

          desc '企业排名指标', hidden: true, tags: ['starProject'], success: {
            code: 201
          }, detail: ''
          params do
            requires :company_projects, type: Array do
              requires :company, type: String, desc: '企业名称'
              requires :projects, type: Array[String], desc: '该企业的项目列表'
            end
            requires :start_time, type: DateTime, desc: '开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
            requires :end_time, type: DateTime, desc: '结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
            optional :top_num, type: Integer, desc: 'topn', documentation: { param_type: 'body', example: 10 }
            requires :sort_by, type: String, desc: '排序字段', documentation: { param_type: 'body', example: 'community_support_score' }
            requires :direction, type: String, desc: '排序方向', documentation: { param_type: 'body', example: 'desc' }

          end
          post :company_rank do
            # 企业排名指标   传参： 组织： 项目名
            # 获取 各企业的 贡献人数分布  和 项目代码   ，

            company_projects = params[:company_projects]
            end_date = params[:end_time]
            begin_date = params[:start_time]

            sort_by = params[:sort_by]
            direction = params[:direction]
            top_num = params[:top_num]

            # 3. 构建 URL 映射
            # expanded_map = {} # { raw_url => [internal_urls] }
            project_to_company_map = {}

            company_projects.each do |cp|
              company_name = cp[:company]
              cp[:projects].each do |raw_url|
                # 处理 "url1,url2" 这样的复合 URL
                internal_urls = raw_url.split(',').map(&:strip).reject(&:empty?)

                internal_urls.each do |internal_url|
                  project_to_company_map[internal_url] = company_name
                end
              end
            end

            # 所有需要查询的 "内部URL"
            all_internal_urls = project_to_company_map.keys.uniq

            next { code: 201, data: [] } if all_internal_urls.empty?

            # 4. 构建 "内部URL" -> "查询Label" 的映射 (处理社区URL)
            query_label_for_url = {} # { internal_url => query_label }

            all_internal_urls.each do |url|
              query_label_for_url[url] = url # 默认 label 就是 URL
            end

            # 所有需要去 ES 查询的 labels
            query_labels = query_label_for_url.values.uniq

            # 5. 查询数据 (获取时间范围内的最新指标)
            activities = get_index_last_data_scroll(ActivityMetric, query_labels, ['label', 'contributor_count'], begin_date, end_date)
            codequality_activities = get_index_data_scroll(CodequalityMetric, query_labels, ['label', 'lines_added_frequency'], begin_date, end_date)

            # 6. 将数据从 "Label" 映射回 "内部URL"
            #    (确保一个 label 只对应一个 internal_url，防止数据重复计算)
            label_to_internal = {}
            query_label_for_url.each { |internal_url, label| label_to_internal[label] ||= internal_url }

            merged_by_internal_url = {}

            merge_into = lambda do |items, merged_hash|
              items.each do |item|
                label = item[:label] || item["label"]
                internal_url = label_to_internal[label]
                next unless internal_url # 如果 label 找不到对应的 URL，跳过

                merged_hash[internal_url] ||= { label: internal_url }

                item.each do |k, v|
                  next if k.to_s == "label"
                  merged_hash[internal_url][k.to_sym] = v
                end
              end
            end

            merge_into.call(activities, merged_by_internal_url)

            codequality_activities.each do |item|
              label = item[:label] || item["label"]
              internal_url = label_to_internal[label]
              next unless internal_url

              merged_by_internal_url[internal_url] ||= { label: internal_url }

              # lines_added_frequency 是每周平均值 → 转成当周总数
              avg_weekly_lines = item[:lines_added_frequency].to_f
              weekly_total_lines = avg_weekly_lines * 7

              merged_by_internal_url[internal_url][:weekly_lines_added] ||= 0
              merged_by_internal_url[internal_url][:weekly_lines_added] += weekly_total_lines
            end

            # 7. 按公司聚合指标 (SUM)
            company_metrics = {}

            # 初始化所有公司，确保即使没数据也返回 0
            company_projects.each do |cp|
              company_name = cp[:company]
              company_metrics[company_name] ||= {
                company: company_name,
                contributor_count: 0,
                lines_added_frequency: 0
              }
            end

            # 遍历每个项目的指标，累加到对应的公司
            merged_by_internal_url.each do |internal_url, metrics|
              company_name = project_to_company_map[internal_url]
              next unless company_name # 安全检查
              company_data = company_metrics[company_name]
              company_data[:contributor_count] += metrics[:contributor_count].to_f
              company_data[:lines_added_frequency] += metrics[:weekly_lines_added].to_f
            end

            # 8. 排序
            results = company_metrics.values

            if sort_by && !sort_by.strip.empty?
              sort_by_key = sort_by.to_sym
              results.sort_by! do |item|
                raw = item[sort_by_key]
                if raw.nil?
                  [1, 0] # nil 排在最后
                else
                  [0, raw]
                end
              end
              results.reverse! if direction&.downcase == 'desc'
            end

            if top_num.present?
              top_num = top_num.to_i
              results = results.first(top_num) if top_num > 0
            end

            # 9. 返回结果
            { code: 201, data: results }
          end

          desc '项目综合排名 协作开发指数，社区服务与支撑，活跃度，组织活跃度', hidden: true, tags: ['starProject'], success: {
            code: 201
          }, detail: ''
          params do
            requires :project_urls, type: Array[String], desc: '项目地址', documentation: { param_type: 'body' }
            requires :start_time, type: DateTime, desc: '开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
            requires :end_time, type: DateTime, desc: '结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
            requires :time_type, type: String, desc: '时间类型', documentation: { param_type: 'body', example: 'year' }
            optional :top_num, type: Integer, desc: 'topn', documentation: { param_type: 'body', example: 10 }

            requires :sort_by, type: String, desc: '排序字段', documentation: { param_type: 'body', example: 'community_support_score' }
            requires :direction, type: String, desc: '排序方向', documentation: { param_type: 'body', example: 'desc' }

          end
          post :project_model_rank do
            # 项目综合排名
            unique_urls = params[:project_urls].uniq

            begin_date = params[:start_time]
            end_date = params[:end_time]
            time_type = params[:time_type]
            sort_by = params[:sort_by]
            direction = params[:direction]
            top_num = params[:top_num]

            # 处理社区 URL → 社区名称 label 查询
            query_labels_map = {} # { 原始URL => 查询用label }

            unique_urls.each do |url|
              # 提取 path 最后部分（去掉域名）
              # 例如 https://gitee.com/openeuler → ["openeuler"]
              #     https://gitee.com/openeuler/kernel → ["openeuler", "kernel"]
              path_parts = URI(url).path.split('/').reject(&:empty?)

              # 默认查询用 label = 原始 URL
              query_labels_map[url] = url

              # 只有 owner 层，才调用 get_community_name
              if path_parts.length == 1
                owner = path_parts.last

                community_info = get_community_name(owner)

                if community_info.is_a?(Array) && community_info.first && community_info.first[:level] == "community"
                  community_label = community_info.first[:label]
                  query_labels_map[url] = community_label
                end

              end
            end

            query_labels = query_labels_map.values.uniq

            activities = get_index_last_data_scroll(ActivityMetric, query_labels, ['label', 'activity_score', 'grimoire_creation_date'], begin_date, end_date)
            community_activities = get_index_last_data_scroll(CommunityMetric, query_labels, ['label', 'community_support_score', 'grimoire_creation_date'], begin_date, end_date)
            codequality_activities = get_index_last_data_scroll(CodequalityMetric, query_labels, ['label', 'code_quality_guarantee', 'grimoire_creation_date'], begin_date, end_date)
            group_activities = get_index_last_data_scroll(GroupActivityMetric, query_labels, ['label', 'organizations_activity', 'grimoire_creation_date'], begin_date, end_date)

            # 合并结果到按 label 的哈希
            merged = {}

            merge_into = lambda do |items|
              items.each do |item|
                query_label = item[:label] || item["label"]
                next unless query_label

                original_url = query_labels_map.key(query_label)
                next unless original_url

                merged[original_url] ||= { label: original_url }

                item.each do |k, v|
                  next if k.to_s == "label"
                  merged[original_url][k.to_sym] = v
                end
              end
            end

            merge_into.call(activities)
            merge_into.call(community_activities)
            merge_into.call(codequality_activities)
            merge_into.call(group_activities)

            # 确保所有请求中的 URL 都在结果里
            # unique_urls.each do |u|
            #   merged[u] ||= { label: u }
            # end

            results = merged.values

            if sort_by && !sort_by.strip.empty?
              results.sort_by! do |item|
                raw = item[sort_by.to_sym] || item[sort_by.to_s]
                # 统一处理 nil → 使用 [nil, 0] 结构进行排序
                if raw.nil?
                  [1, 0] # nil 的排到最后
                else
                  [0, raw] # 有值的排前面
                end
              end

              results.reverse! if direction&.downcase == 'desc'
            end

            if top_num.present?
              top_num = top_num.to_i
              results = results.first(top_num) if top_num > 0
            end
            #
            { code: 201, data: results }
          end

          desc '项目贡献人数分布', hidden: true, tags: ['starProject'], success: {
            code: 201
          }, detail: ''
          params do
            requires :project_urls, type: Array[String], desc: '项目地址', documentation: { param_type: 'body' }
            requires :start_time, type: DateTime, desc: '开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
            requires :end_time, type: DateTime, desc: '结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
            requires :time_type, type: String, desc: '时间类型', documentation: { param_type: 'body', example: 'year' }
          end
          post :contributor_count do
            unique_raw_urls = params[:project_urls].uniq

            begin_date = params[:start_time]
            end_date = params[:end_time]
            time_type = params[:time_type] # year / month / day

            # =======================================================
            # (1) 拆出内部 URL 列表
            # =======================================================
            expanded_map = {} # { "a,b" => ["a","b"] }

            unique_raw_urls.each do |raw|
              expanded_map[raw] = raw.split(',').map(&:strip).reject(&:empty?)
            end

            # =======================================================
            # (2) 找到每个内部 URL 的查询 label（社区 owner 映射）
            # =======================================================
            query_label_for_url = {} # { internal_url => label }
            owner_cache = {} # { owner => community_label }

            expanded_map.each do |_raw, urls|
              urls.each do |url|
                begin
                  parts = URI(url).path.split('/').reject(&:empty?)
                rescue
                  parts = []
                end

                # 默认直接用 URL 当 label
                query_label_for_url[url] = url

                # owner /org
                if parts.length == 1
                  owner = parts.first.downcase

                  unless owner_cache.key?(owner)
                    info = get_community_name(owner) # 你已重构为 Hash 返回
                    if info.any? && info.first[:level] == "community"
                      owner_cache[owner] = info.first[:label]
                    else
                      owner_cache[owner] = nil
                    end
                  end

                  query_label_for_url[url] = owner_cache[owner] if owner_cache[owner]
                end
              end
            end

            # 所有需要查询的 label
            query_labels = query_label_for_url.values.uniq

            # =======================================================
            # (3) 调用 ES
            # =======================================================
            activities = get_index_data_scroll(
              ActivityMetric,
              query_labels,
              ['label', 'contributor_count', 'grimoire_creation_date'],
              begin_date,
              end_date
            )

            # =======================================================
            # (4) 修复数据翻倍！
            # label → internal_url 强制一对一
            # =======================================================
            label_to_internal = {}

            query_label_for_url.each do |internal_url, label|
              label_to_internal[label] ||= internal_url
            end

            # =======================================================
            # (5) 归类 OS 数据（不会翻倍）
            # =======================================================
            grouped_internal = {} # { internal_url => [records] }

            activities.each do |item|
              label = item[:label] || item['label']
              internal = label_to_internal[label]
              next unless internal

              grouped_internal[internal] ||= []
              grouped_internal[internal] << {
                date: item[:grimoire_creation_date] || item['grimoire_creation_date'],
                value: item[:contributor_count] || item['contributor_count']
              }
            end

            # =======================================================
            # (6) 原始输入 URL 多内部 URL 合并
            # =======================================================
            final_grouped = {}

            expanded_map.each do |raw, urls|
              final_grouped[raw] = urls.flat_map { |u| grouped_internal[u] || [] }
            end

            # =======================================================
            # (7) 时间聚合
            # =======================================================
            aggregated = {}

            final_grouped.each do |raw, records|
              if records.empty?
                aggregated[raw] = []
                next
              end

              sorted = records.sort_by { |r| Time.parse(r[:date].to_s) }

              case time_type
              when "year"
                aggregated[raw] = sorted.group_by { |r| Time.parse(r[:date]).year }
                                        .map do |year, items|
                  { date: Date.new(year, 12, 31).to_s,
                    value: items.max_by { |x| Time.parse(x[:date].to_s) }[:value] }
                end

              when "month"
                aggregated[raw] = sorted.group_by { |r| t = Time.parse(r[:date]); [t.year, t.month] }
                                        .map do |(y, m), items|
                  { date: Date.new(y, m, -1).to_s,
                    value: items.max_by { |x| Time.parse(x[:date].to_s) }[:value] }
                end

              else
                # day
                aggregated[raw] = sorted.map do |i|
                  { date: Time.parse(i[:date].to_s).to_date.to_s, value: i[:value] }
                end
              end
            end

            # =======================================================
            # (8) 按用户输入原样返回
            # =======================================================
            result = unique_raw_urls.map do |raw|
              {
                repo_url: raw,
                data: aggregated[raw] || []
              }
            end

            { code: 201, data: result }

          end

          desc '项目代码提交分布', hidden: true, tags: ['starProject'], success: {
            code: 201
          }, detail: ''
          params do
            requires :project_urls, type: Array[String], desc: '项目地址', documentation: { param_type: 'body' }
            requires :start_time, type: DateTime, desc: '开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
            requires :end_time, type: DateTime, desc: '结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
            requires :time_type, type: String, desc: '结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
          end
          post :code_line_count do
            # ==== 参数 ====
            unique_raw_urls = params[:project_urls].uniq
            begin_date = params[:start_time]
            end_date = params[:end_time]
            time_type = params[:time_type]

            expanded_map = {} # { 原始字符串 => [内部URL] }

            unique_raw_urls.each do |raw|
              expanded_map[raw] = raw.split(',').map(&:strip).reject(&:empty?)
            end

            query_label_for_url = {} # { internal_url => label }
            owner_cache = {} # { owner => community_label }

            expanded_map.each do |raw, urls|
              urls.each do |url|
                begin
                  path_parts = URI(url).path.split('/').reject(&:empty?)
                rescue
                  path_parts = []
                end

                # 默认直接用 URL 作为 label
                query_label_for_url[url] = url

                # owner-level
                if path_parts.length == 1
                  owner = path_parts.first.downcase

                  unless owner_cache.key?(owner)
                    info = get_community_name(owner)
                    if info.any? && info.first[:level] == "community"
                      owner_cache[owner] = info.first[:label]
                    else
                      owner_cache[owner] = nil
                    end
                  end

                  if owner_cache[owner]
                    query_label_for_url[url] = owner_cache[owner]
                  end
                end
              end
            end

            query_labels = query_label_for_url.values.uniq

            activities = get_index_data_scroll(
              CodequalityMetric,
              query_labels,
              ['label', 'lines_added_frequency', 'lines_removed_frequency', 'grimoire_creation_date'],
              begin_date,
              end_date
            )

            label_to_internal = {}

            query_label_for_url.each do |internal_url, label|
              label_to_internal[label] ||= internal_url
            end

            grouped_internal = {}

            activities.each do |item|
              q_label = item[:label] || item["label"]
              matched_url = label_to_internal[q_label]
              next unless matched_url

              grouped_internal[matched_url] ||= []
              grouped_internal[matched_url] << {
                date: item[:grimoire_creation_date] || item['grimoire_creation_date'],
                value: (item[:lines_added_frequency] || item['lines_added_frequency']).to_f
              }
            end

            final_grouped = {}

            expanded_map.each do |raw, urls|
              final_grouped[raw] = urls.flat_map { |u| grouped_internal[u] || [] }
            end

            # 按时间类型聚合
            aggregated = {}

            final_grouped.each do |raw, records|
              if records.empty?
                aggregated[raw] = []
                next
              end

              sorted = records.sort_by { |x| Time.parse(x[:date].to_s) }

              case time_type
              when "year"
                aggregated[raw] = sorted.group_by { |r| Time.parse(r[:date]).year }
                                        .map { |year, rows|
                                          { date: Date.new(year, 12, 31).to_s, value: rows.sum { |x| x[:value].round } }
                                        }

              when "month"
                aggregated[raw] = sorted.group_by { |r| t = Time.parse(r[:date]); [t.year, t.month] }
                                        .map { |(y, m), rows|
                                          { date: Date.new(y, m, -1).to_s, value: rows.sum { |x| x[:value].round } }
                                        }

              else
                # day
                aggregated[raw] = sorted.map { |x|
                  { date: Time.parse(x[:date]).to_date.to_s, value: x[:value].round }
                }
              end
            end

            result = unique_raw_urls.map do |raw|
              {
                repo_url: raw,
                data: aggregated[raw] || []
              }
            end

            { code: 201, data: result }

          end

        end
      end
    end
  end
end


