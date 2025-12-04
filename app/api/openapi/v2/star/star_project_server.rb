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

          def get_index_last_data_agg(base_indexer, urls, field, begin_date, end_date)
            safe_urls = Array(urls).flatten.compact.uniq.reject(&:blank?)
            if safe_urls.empty?
              Rails.logger.info("【Skip ES】get_index_last_data_agg skipped because urls is empty.")
              return []
            end

            source_fields = field.is_a?(Array) ? field : [field]

            criteria = base_indexer
                         .must(terms: { 'label.keyword' => safe_urls })
                         .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
                         .per(0) # 不返回 hits，只取聚合

            criteria = criteria.aggregate(
              projects_group: {
                terms: {
                  field: 'label.keyword',
                  size: safe_urls.length + 20 # 保证 bucket 够大
                },
                aggs: {
                  latest_record: {
                    top_hits: {
                      size: 1,
                      sort: [{ grimoire_creation_date: { order: 'desc' } }],
                      _source: { includes: source_fields }
                    }
                  }
                }
              }
            )

            begin
              raw_aggs = criteria.aggregations
              buckets = raw_aggs.dig('projects_group', 'buckets') || []

              latest_hits = buckets.map do |bucket|
                hits_container = bucket.dig('latest_record', 'hits', 'hits')
                next unless hits_container && hits_container.first

                hit_source = hits_container.first['_source']

                entry = { label: bucket['key'] }
                source_fields.each do |f|
                  next if f.to_s == 'label'
                  entry[f.to_sym] = hit_source[f.to_s]
                end

                entry
              end.compact

              latest_hits

            rescue SearchFlip::ResponseError => e

              Rails.logger.error("【ES Error】get_index_last_data_agg failed: #{e.message}")
              return []
            end

          end

          def get_community(keyword)
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

          def get_community_name(keyword)
            # 根据 keyword 获取社区名称
            project = StarProject.find_by(repo_url: keyword)
            project&.project_name
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
            # 去除空项
            input_items = params[:project_urls].uniq.reject(&:blank?)

            input_to_sub_urls_map = {}

            # 所有需要去数据库查的 URL (去重后)
            all_atomic_urls_to_query = []


            short_name_map = {}

            input_items.each do |raw_item|
              # 1. 拆分逗号 (处理 "url1,url2" 的情况)
              sub_urls = raw_item.split(',').map do |u|
                u.strip.chomp('/') # 去除首尾空格，并去除末尾的一个 '/'
              end.reject(&:empty?)

              input_to_sub_urls_map[raw_item] = sub_urls

              sub_urls.each do |url|
                all_atomic_urls_to_query << url

                # 尝试提取短名 (处理社区名称)
                begin
                  path_parts = URI(url).path.split('/').reject(&:empty?)
                  if path_parts.length == 1
                    short_name = path_parts.last
                    short_name_map[short_name] = url
                    all_atomic_urls_to_query << short_name
                  end
                rescue URI::InvalidURIError
                  next
                end
              end
            end

            all_atomic_urls_to_query.uniq!


            # 查 Subject 表
            subjects_info = Subject.where(label: all_atomic_urls_to_query).pluck(:id, :label, :level)

            # 建立映射: { "https://gitee.com/oh" => ["repo_1", "repo_2"] }
            atomic_url_expansion_map = {}

            # 待查子项目的社区 ID
            community_ids = []
            community_id_to_url = {}

            subjects_info.each do |s_id, s_label, s_level|
              # 找到这个 label 对应的 完整URL (如果是短名查出来的，要映射回 URL)
              # 如果 s_label 本身就是完整 URL，short_name_map[s_label] 为 nil，取 s_label 自身
              original_atomic_url = short_name_map[s_label] || s_label

              if s_level == 'community'
                community_ids << s_id
                community_id_to_url[s_id] = original_atomic_url
                atomic_url_expansion_map[original_atomic_url] ||= [] # 初始化
              else
                # 是普通项目
                atomic_url_expansion_map[original_atomic_url] ||= []
                atomic_url_expansion_map[original_atomic_url] << s_label
              end
            end

            # 查 SubjectRefs 展开社区
            if community_ids.present?
              refs = SubjectRef.where(parent_id: community_ids).pluck(:parent_id, :child_id)
              all_child_ids = refs.map { |_, c_id| c_id }
              child_id_to_label = Subject.where(id: all_child_ids).pluck(:id, :label).to_h

              refs.each do |p_id, c_id|
                parent_url = community_id_to_url[p_id]
                child_label = child_id_to_label[c_id]
                if parent_url && child_label
                  atomic_url_expansion_map[parent_url] << child_label
                end
              end
            end


            final_expansion_map = {} # { "gitee/oh,gitcode/oh" => ["repo_A", "repo_B", "repo_C"] }

            input_to_sub_urls_map.each do |raw_item, sub_urls|
              resolved_repos = []

              sub_urls.each do |sub_url|
                # 获取该原子 URL 展开后的列表
                # 如果 map 里没有(数据库没查到)，就认为它本身是个项目
                expanded = atomic_url_expansion_map[sub_url]
                if expanded.present?
                  resolved_repos.concat(expanded)
                else
                  resolved_repos << sub_url
                end
              end

              final_expansion_map[raw_item] = resolved_repos.uniq
            end

            all_target_urls = final_expansion_map.values.flatten.uniq
            repo_star_data = {}

            github_urls = all_target_urls.select { |u| u.include?('github.com') }
            gitee_urls = all_target_urls.select { |u| u.include?('gitee.com') }
            gitcode_urls = all_target_urls.select { |u| u.include?('gitcode.com') }

            [
              { index: GithubRepoEnrich, urls: github_urls },
              { index: GitcodeRepoEnrich, urls: gitcode_urls },
              { index: GiteeRepoEnrich, urls: gitee_urls }
            ].each do |group|
              next if group[:urls].empty?
              safe_urls = group[:urls]
              target_field = 'tag'

              # ES 聚合查询 (同之前逻辑)
              criteria = group[:index]
                           .must(terms: { target_field => safe_urls })
                           .per(0)
                           .aggregate(
                             by_project_url: {
                               terms: { field: "#{target_field}", size: safe_urls.length + 100 },
                               aggs: {
                                 latest_data: {
                                   top_hits: {
                                     size: 1,
                                     sort: [{ grimoire_creation_date: { order: 'desc' } }],
                                     _source: { includes: ['stargazers_count'] }
                                   }
                                 }
                               }
                             }
                           )

              begin
                raw_aggs = criteria.aggregations
                buckets = raw_aggs.dig('by_project_url', 'buckets') || []
                buckets.each do |bucket|
                  url = bucket['key']
                  hit = bucket.dig('latest_data', 'hits', 'hits', 0, '_source')
                  repo_star_data[url] = hit['stargazers_count'].to_i if hit
                end
              rescue SearchFlip::ResponseError => e
                Rails.logger.error "StarCount Logic Error: #{e.message}"
              end
            end


            # 汇总输出
            final_results = input_items.map do |raw_item|
              # 找到该项对应的所有底层项目
              child_repos = final_expansion_map[raw_item]

              total_stars = 0

              child_repos.each do |repo_url|
                count = repo_star_data[repo_url]
                total_stars += count if count
              end

              {
                repo_url: raw_item, # 这里的 repo_url 就是传入的 "https://... , https://..."
                star_count: total_stars
              }
            end

            { code: 201, data: final_results }
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
            #  { 原始URL => 查询用label }
            query_labels_map = {}

            unique_urls.each do |url|
              # 提取 path 最后部分（去掉域名）
              path_parts = URI(url).path.split('/').reject(&:empty?)

              # 默认查询用 label = 原始 URL
              query_labels_map[url] = url

              # 只有 owner 层，才调用 get_community_name
              if path_parts.length == 1
                community_name = get_community_name(url)
                query_labels_map[url] = community_name

                # owner = path_parts.last
                # community_info = get_community(owner)
                # if community_info.is_a?(Array) && community_info.first && community_info.first[:level] == "community"
                #   community_label = community_info.first[:label]
                #   query_labels_map[url] = community_label
                # end

              end
            end

            query_labels = query_labels_map.values.uniq

            activities = get_index_last_data_agg(ActivityMetric, query_labels, ['label', 'activity_score', 'grimoire_creation_date'], begin_date, end_date)
            community_activities = get_index_last_data_agg(CommunityMetric, query_labels, ['label', 'community_support_score', 'grimoire_creation_date'], begin_date, end_date)
            codequality_activities = get_index_last_data_agg(CodequalityMetric, query_labels, ['label', 'code_quality_guarantee', 'grimoire_creation_date'], begin_date, end_date)
            group_activities = get_index_last_data_agg(GroupActivityMetric, query_labels, ['label', 'organizations_activity', 'grimoire_creation_date'], begin_date, end_date)

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
                  # owner = parts.first.downcase
                  #
                  # unless owner_cache.key?(owner)
                  #   info = get_community_name(owner)
                  #   if info.any? && info.first[:level] == "community"
                  #     owner_cache[owner] = info.first[:label]
                  #   else
                  #     owner_cache[owner] = nil
                  #   end
                  # end
                  # query_label_for_url[url] = owner_cache[owner] if owner_cache[owner]
                  community_name = get_community_name(url)
                  query_label_for_url[url] = community_name

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

                  # unless owner_cache.key?(owner)
                  #   info = get_community_name(owner)
                  #   if info.any? && info.first[:level] == "community"
                  #     owner_cache[owner] = info.first[:label]
                  #   else
                  #     owner_cache[owner] = nil
                  #   end
                  # end
                  #
                  # if owner_cache[owner]
                  #   query_label_for_url[url] = owner_cache[owner]
                  # end
                  community_name = get_community_name(url)
                  query_label_for_url[url] = community_name

                end
              end
            end

            query_labels = query_label_for_url.values.uniq

            begin

              activities = get_index_data_scroll(
                CodequalityMetric,
                query_labels,
                ['label', 'lines_added_frequency', 'lines_removed_frequency', 'grimoire_creation_date'],
                begin_date,
                end_date
              )

            rescue => e
              Rails.logger.info( "【Error】code_line_count ES 查询失败: #{e.message} " )

            end

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


