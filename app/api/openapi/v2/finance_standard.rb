# frozen_string_literal: true

module Openapi
  module V2
    class FinanceStandard < Grape::API
      version 'v2', using: :path
      prefix :api
      format :json
      GITHUB_TOKEN = ENV.fetch('GITHUB_API_TOKEN')
      RAW_GITHUB_ENDPOINT = 'https://raw.githubusercontent.com'
      GITHUB_API_ENDPOINT = 'https://api.github.com'

      helpers Openapi::SharedParams::AuthHelpers
      helpers Openapi::SharedParams::ErrorHelpers

      helpers do
        def check_version_exists(label, version_number)
          puts "Checking version #{label}, #{version_number}"

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, 'repo', GiteeReleasesEnrich, GithubReleasesEnrich)
          releases = indexer.get_releases(repo_urls)
          flag = releases.include?(version_number)
          if flag
            return true, []
          end

          owner, repo = parse_project_url(label)

          project_releases = []
          project_tags = []

          if label.include?("github.com")
            project_releases = fetch_github_releases(owner, repo)
            return true, [] if project_releases.include?(version_number)

            project_tags = fetch_github_tags(owner, repo)
            return true, [] if project_tags.include?(version_number)

          elsif label.include?("gitee.com")
            project_tags = fetch_gitee_tags(owner, repo)
            return true, [] if project_tags.include?(version_number)
          end

          return false, (releases + project_releases + project_tags).uniq
        end

        # 提取 owner 和 repo
        def parse_project_url(url)
          uri = URI.parse(url)
          parts = uri.path.split('/')
          owner = parts[1]
          repo = parts[2].gsub(/.git$/, '')
          [owner, repo]
        end


        def fetch_github_releases(owner, repo)
          response = github_conn.get("repos/#{owner}/#{repo}/releases")
          return [] unless response.success?

          json = JSON.parse(response.body)
          json.map { |release| release["tag_name"] }
        rescue => e
          Rails.logger.error "GitHub releases error: #{e.message}"
          []
        end

        # 使用 Faraday 获取 tags
        def fetch_github_tags(owner, repo)
          response = github_conn.get("repos/#{owner}/#{repo}/tags")
          return [] unless response.success?

          json = JSON.parse(response.body)
          json.map { |tag| tag["name"] }
        rescue => e
          Rails.logger.error "GitHub tags error: #{e.message}"
          []
        end

        def github_conn
          @github_conn ||= Faraday.new(url: "https://api.github.com") do |f|
            f.request :url_encoded
            f.headers['Accept'] = 'application/vnd.github+json'
            f.headers['User-Agent'] = 'VersionChecker/1.0'

            if ENV['GITHUB_API_TOKEN']
              f.headers['Authorization'] = "Bearer #{ENV['GITHUB_API_TOKEN']}"
            end

            f.adapter Faraday.default_adapter
          end
        end

        # -------- Gitee API --------
        def fetch_gitee_tags(owner, repo)
          response = gitee_conn.get("repos/#{owner}/#{repo}/tags")
          # puts "Requesting: #{gitee_conn.build_url("repos/#{owner}/#{repo}/tags")}"
          return [] unless response.success?
          JSON.parse(response.body).map { |t| t["name"] }
        rescue => e
          Rails.logger.error "Gitee tags error: #{e.message}"
          []
        end

        def gitee_conn
          @gitee_conn ||= Faraday.new(url: "https://gitee.com/api/v5") do |f|
            f.headers['User-Agent'] = 'VersionChecker/1.0'
            f.params['access_token'] = ENV['GITEE_TOKEN'] if ENV['GITEE_TOKEN']
            f.adapter Faraday.default_adapter
          end
        end
      end

      rescue_from :all do |e|
        case e
        when Grape::Exceptions::ValidationErrors
          handle_validation_error(e)
        when SearchFlip::ResponseError
          handle_open_search_error(e)
        when Openapi::Entities::InvalidVersionNumberError
          handle_release_error(e)
        else
          handle_generic_error(e)
        end
      end



      before { require_token! }
      before do
        token = params[:access_token]
        Openapi::SharedParams::RateLimiter.check_token!(token)
      end

      helpers do
        def get_projects(new_datasets)
          filtered_rows = new_datasets.map do |row|
            row.to_h.merge(label: ShortenedLabel.normalize_label(row[:label]))
          end
          raise ValidateFailed.new(I18n.t('lab_models.invalid_dataset')) if filtered_rows.blank?
          filtered_rows
        end
      end

      resource :financeStandardProjectVersion do
        # desc 'trigger FinanceStandard Project'
        desc 'Trigger The Finance Standard Metric / 触发执行金融指标', tags: ['Scene Invocation / 场景调用'], success: {
          code: 201, model: Openapi::Entities::TriggerResponse
        }, detail: <<~DETAIL
          This interface is used to trigger the execution and analysis of financial metrics.
          Request Parameters:
          datasets (array, required): A list of datasets. Each element in the array must include:
            label (string): Repository address, e.g., "https://github.com/rabbitmq/rabbitmq-server".
            versionNumber (string): Version number, e.g., "v4.0.7".
        
          Interface Logic:
          Submits a task based on the provided dataset information and invokes the financial metrics model for processing.

          Response:
          status (boolean): Indicates whether the analysis task was successfully submitted. / 该接口用于触发金融指标的执行分析。
                    请求参数说明：
                    datasets (数组)：必填。数据集列表，每个元素包含：
                      label (字符串)：仓库地址，例如 "https://github.com/rabbitmq/rabbitmq-server"
                      versionNumber (字符串)：版本号，例如 "v4.0.7"
                    接口逻辑说明：
                    根据传入的数据集信息，提交任务，调用金融指标模型进行处理。
                    返回值：
                     status (布尔值)：状态值，表示分析任务是否提交成功。                    

        DETAIL
        params do
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :datasets, type: Array, desc: '数据集列表', documentation: { param_type: 'body', example: [{ label: 'https://github.com/rabbitmq/rabbitmq-server', versionNumber: 'v4.0.7' }] } do
            requires :label, type: String, desc: '仓库地址', documentation: { param_type: 'body', example: 'https://github.com/rabbitmq/rabbitmq-server' }
            requires :versionNumber, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.7' }
          end
        end
        post :trigger do
          status = nil
          datasets = params[:datasets]
          projects = get_projects(datasets)

          model = LabModel.find_by(id: 298)
          version = LabModelVersion.find_by(id: 358)

          projects.each do |project|
            # 查询 版本，先查询release enrich,没有的话去拉GitHub api release 和 tag 如果里面的版本信息和versionNumber对的上则进行下一步 否则返回版本信息
            flag, releases = check_version_exists(project[:label], project['versionNumber'])
            unless flag
              raise Openapi::Entities::InvalidVersionNumberError, "releases: #{releases}"
            end
            status = CustomAnalyzeProjectVersionServer.new(user: nil, model: model, version: version, project: project[:label], version_number: project['versionNumber'], level: 'repo').execute
          end
          status
        end

        # desc 'query trigger status for a given project'
        desc 'Query Trigger Status / 获取给定项目的金融指标执行状态', tags: ['Scene Invocation / 场景调用'], success: {
          code: 201, model: Openapi::Entities::StatusQueryResponse
        }, detail: <<~DETAIL
           This interface is used to query the execution status of financial metrics analysis for a specified project and version.
           Request Parameters:
           label (string, required):
           Project repository address, e.g., "https://github.com/rabbitmq/rabbitmq-server".
           versionNumber (string, required): Project version number, e.g., "v4.0.7".
           Interface Logic:
           Queries the current execution status of the financial metrics analysis task based on the provided project repository address and version number.

           Response:
           trigger_status (string): Execution status of the task. Possible values include:
            pending: Task is in the execution queue and will start shortly.
            progress: Task is currently being processed.
            success: Task has completed successfully.
            error: An error occurred during execution.
            canceled: Task was canceled.
            unsubmit: Task has not been submitted. / 该接口用于查询指定项目及版本号的金融指标执行状态。
           请求参数说明：
            label (字符串)：必填。项目地址，如 "https://github.com/rabbitmq/rabbitmq-server"
            versionNumber (字符串)。必填：项目版本号，如 "v4.0.7"
           接口逻辑说明：
           根据传入的项目地址及版本号，查询对应金融指标分析任务的当前执行状态。
           返回值：
            trigger_status (字符串)：任务执行状态，可能的值包括：
            pending：已经提交执行队列，将要执行;
            progress：正在执行;
            success：执行完毕;
            error：执行报错;
            canceled：任务取消;
            unsumbit：未提交任务。
        DETAIL
        params do
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :label, type: String, desc: '项目地址', documentation: { param_type: 'body', example: 'https://github.com/rabbitmq/rabbitmq-server' }
          optional :versionNumber, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.7' }
        end
        post :statusQuery do
          label = ShortenedLabel.normalize_label(params[:label])
          version_number = params[:versionNumber]
          model = LabModel.find_by(id: 298)
          version = LabModelVersion.find_by(id: 358)
          status = CustomAnalyzeProjectVersionServer.new(user: nil, model: model, version: version, project: label,
                                                         version_number: version_number, level: 'repo').check_task_status_query

          { trigger_status: status }
        end
      end

    end
  end
end
