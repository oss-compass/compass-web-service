# frozen_string_literal: true

module Openapi
  module V2
    module Report
      class ReportServer < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json

        helpers Openapi::SharedParams::AuthHelpers
        helpers Openapi::SharedParams::ErrorHelpers

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
          include Pagy::Backend
        end

        resource :report do

          desc 'Create Other Report / 创建其他类型报告', tags: ['V2 API'], success: {
            code: 201, model: Openapi::Entities::OtherReportCreateResponse
          }, detail: <<~DETAIL
            Create a report of type other, reference the incubation report creation of CreateTpcSoftwareSelectionReport.
            创建 other 类型报告，参考 CreateTpcSoftwareSelectionReport 的孵化报告创建。
          DETAIL
          params do
            requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
            optional :label, type: String, desc: 'repo or project label(optional, default OpenHarmony-TPC) / 仓库或项目标签(可选，默认 OpenHarmony-TPC)', default: 'OpenHarmony-TPC', documentation: { param_type: 'body', example: 'OpenHarmony-TPC' }
            optional :level, type: String, desc: 'repo or community(optional, default community) / 层级(可选，默认 community)', default: 'community', documentation: { param_type: 'body', example: 'community' }
            requires :name, type: String, desc: 'software name / 软件名称', documentation: { param_type: 'body', example: 'openssl' }
            requires :tpc_software_sig_id, type: Integer, desc: 'tpc software sig id / 所属 SIG id', documentation: { param_type: 'body', example: 1 }
            requires :code_url, type: String, desc: 'code url / 源码地址', documentation: { param_type: 'body', example: 'https://gitee.com/src-openeuler/openssl' }
            requires :programming_language, type: String, desc: 'programming language / 编程语言', documentation: { param_type: 'body', example: 'C' }
            optional :vulnerability_response, type: String, desc: 'vulnerability response(optional, default {code_url}/issues) / 漏洞响应方式(可选，默认 源码地址+/issues)', documentation: { param_type: 'body', example: 'https://gitee.com/src-openeuler/openssl/issues' }
            optional :adaptation_method, type: String, desc: 'adaptation method(optional, default 参考) / 适配方式(可选，默认 参考)', default: '参考', documentation: { param_type: 'body', example: '参考' }
            # optional :architecture_diagrams, type: Array, desc: 'architecture diagrams, list of {filename, base64}, max 5 / 架构图列表(可选，最多 5 张)' do
            #   requires :filename, type: String, desc: 'image filename / 图片文件名'
            #   requires :base64, type: String, desc: 'image base64 data, Data URIs form: data:image/png;base64,[base64 data] / 图片 base64 数据'
            # end
            optional :oh_commit_sha, type: String, desc: 'oh commit sha(optional) / OpenHarmony 提交号(可选)', documentation: { param_type: 'body', example: 'a1b2c3d4e5' }
            optional :upstream_collaboration_strategy, type: Integer, desc: 'upstream collaboration strategy(optional, default 0) / 上游协作策略(可选，默认 0)', default: 0, documentation: { param_type: 'body', example: 0 }
            optional :upstream_communication_link, type: String, desc: 'upstream communication link(optional, default {code_url}/issues) / 上游沟通链接(可选，默认 源码地址+/issues)', documentation: { param_type: 'body', example: 'https://gitee.com/src-openeuler/openssl/issues' }
            optional :report_category, type: Integer, desc: 'report category(optional) / 报告分类(可选)', documentation: { param_type: 'body', example: 0 }
          end
          post :create_report do
            label = ShortenedLabel.normalize_label(params[:label].presence || 'OpenHarmony-TPC')
            level = params[:level].presence || 'community'
            code_url = params[:code_url]
            vulnerability_response = params[:vulnerability_response].presence || "#{code_url}/issues"
            adaptation_method = params[:adaptation_method].presence || '参考'
            upstream_collaboration_strategy = params[:upstream_collaboration_strategy] || 0
            upstream_communication_link = params[:upstream_communication_link].presence || "#{code_url}/issues"
            report_user = current_user
            raise 'user not found, invalid token' if report_user.nil?

            architecture_diagrams = params[:architecture_diagrams] || []
            raise I18n.t('lab_models.reach_limit') if architecture_diagrams.length > 5

            subject = Subject.find_by(label: label, level: level)
            raise I18n.t('basic.subject_not_exist') if subject.nil?
            tpc_software_other_report = TpcSoftwareOtherReport.find_by(subject_id: subject.id, code_url: code_url)
            raise I18n.t('tpc.software_report_already_exist') if tpc_software_other_report.present?
            raise I18n.t('tpc.software_code_url_invalid') unless TpcSoftwareReportMetric.check_url(code_url)

            report = nil
            ActiveRecord::Base.transaction do
              software_report_data = {
                name: params[:name],
                tpc_software_sig_id: params[:tpc_software_sig_id],
                code_url: code_url,
                programming_language: params[:programming_language],
                vulnerability_response: vulnerability_response,
                adaptation_method: adaptation_method,
                oh_commit_sha: params[:oh_commit_sha],
                upstream_collaboration_strategy: upstream_collaboration_strategy,
                upstream_communication_link: upstream_communication_link,
                report_category: params[:report_category],
                user_id: report_user.id,
                subject_id: subject.id,
                report_type: TpcSoftwareOtherReport::Report_Type_Other,
                manufacturer: '',
                website_url: '',
                short_code: TpcSoftwareOtherReport.generate_short_code
              }
              report = TpcSoftwareOtherReport.create(software_report_data)
              if architecture_diagrams.length > 0
                diagrams_to_attach = architecture_diagrams.map do |architecture_diagram|
                  {
                    data: architecture_diagram[:base64] || architecture_diagram['base64'],
                    filename: architecture_diagram[:filename] || architecture_diagram['filename']
                  }
                end
                report.architecture_diagrams.attach(diagrams_to_attach)
              end
              report.save!

              report_metric = report.tpc_software_report_metrics.create!(
                {
                  code_url: report.code_url,
                  status: TpcSoftwareReportMetric::Status_Progress,
                  status_compass_callback: 0,
                  status_tpc_service_callback: 0,
                  version: TpcSoftwareReportMetric::Version_Default,
                  user_id: report_user.id,
                  subject_id: subject.id,

                  base_repo_name: 10,  #delete
                  base_website_url: 10,  #delete
                  base_code_url: 10,  #delete

                  compliance_license: nil,
                  compliance_dco: nil,
                  compliance_license_compatibility: nil,
                  ecology_patent_risk: nil, #don't do

                  ecology_dependency_acquisition: nil,
                  ecology_code_maintenance: nil,
                  ecology_community_support: nil,
                  ecology_adoption_analysis: nil,  #don't do
                  ecology_software_quality: nil,
                  #ecology_adaptation_method

                  lifecycle_version_normalization: 10,  #delete
                  lifecycle_version_number: 10,  #delete
                  lifecycle_version_lifecycle: nil,

                  security_binary_artifact: nil,
                  security_vulnerability: nil,
                  security_vulnerability_response: TpcSoftwareReportMetric.check_url(vulnerability_response) ? 10 : 6,
                  security_vulnerability_disclosure: 6,  #delete
                  security_history_vulnerability: nil  #delete
                }
              )

              tpc_software_metric_server = TpcSoftwareMetricServer.new({project_url: code_url})
              # tpc_software_metric_server.analyze_metric_by_tpc_service(report.id, report_metric.id, report.oh_commit_sha, TpcSoftwareMetricServer::Report_Type_Other)
              # tpc_software_metric_server.analyze_metric_by_compass(report.id, report_metric.id, TpcSoftwareMetricServer::Report_Type_Other)
            end

            { status: true, message: '', report_id: report.id, short_code: report.short_code }
          rescue => ex
            { status: false, message: ex.message }
          end

          desc 'Trigger Other Report / 重跑其他类型报告分析', tags: ['V2 API'], success: {
            code: 201, model: Openapi::Entities::OtherReportCreateResponse
          }, detail: <<~DETAIL
            Re-run the metric analysis of an other type report, reference TriggerTpcSoftwareSandboxReport.
            Only the report creator or admin can trigger. 重跑 other 报告的指标分析，仅创建人或管理员可操作。
          DETAIL
          params do
            requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
            requires :report_id, type: Integer, desc: 'other report id / 报告 id', documentation: { param_type: 'body', example: 1 }
          end
          post :trigger_report do
            report_user = current_user
            raise 'user not found, invalid token' if report_user.nil?

            other_report = TpcSoftwareOtherReport.find_by(id: params[:report_id])
            raise I18n.t('basic.subject_not_exist') if other_report.nil?
            raise I18n.t('basic.forbidden') unless report_user.is_admin? || other_report.user_id == report_user.id
            report_metric = other_report.tpc_software_report_metrics.find_by(
              tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Other,
              version: TpcSoftwareReportMetric::Version_Default)
            raise I18n.t('basic.subject_not_exist') if report_metric.nil?

            ActiveRecord::Base.transaction do
              report_metric.update!(
                {
                  status: TpcSoftwareReportMetric::Status_Again_Progress,
                  status_compass_callback: 0,
                  status_tpc_service_callback: 0
                }
              )
              tpc_software_metric_server = TpcSoftwareMetricServer.new({project_url: other_report.code_url})
              tpc_software_metric_server.analyze_metric_by_tpc_service(other_report.id, report_metric.id, other_report.oh_commit_sha, TpcSoftwareMetricServer::Report_Type_Other)
              # tpc_software_metric_server.analyze_metric_by_compass(other_report.id, report_metric.id, TpcSoftwareMetricServer::Report_Type_Other)
            end

            { status: true, message: '', report_id: other_report.id, short_code: other_report.short_code }
          rescue => ex
            { status: false, message: ex.message }
          end

          desc 'Query Other Report Detail / 查询其他类型报告详情', tags: ['V2 API'], success: {
            code: 201, model: Openapi::Entities::OtherReportDetailResponse
          }, detail: <<~DETAIL
            Query the detail of one other type report by short code or code url, reference TpcSoftwareSelectionReportQuery.
            按短码或源码地址查询单个 other 报告详情（含指标得分明细与架构图）。
          DETAIL
          params do
            requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
            optional :short_code, type: String, desc: 'report short code / 报告短码', documentation: { param_type: 'body', example: 'o1a2b3c4d' }
            optional :code_url, type: String, desc: 'code url / 源码地址', documentation: { param_type: 'body', example: 'https://gitee.com/src-openeuler/openssl' }
            at_least_one_of :short_code, :code_url
          end
          post :query_report_detail do
            code = params[:short_code].presence || params[:code_url].presence
            report = TpcSoftwareOtherReport.where("short_code = :code OR code_url = :url", code: code, url: code).first
            raise I18n.t('basic.subject_not_exist') if report.nil?

            { status: true, message: '', report: Openapi::Entities::OtherReportDetail.represent(report) }
          rescue => ex
            { status: false, message: ex.message }
          end

          desc 'Query Other Report List / 查询其他类型报告列表', tags: ['V2 API'], success: {
            code: 201, model: Openapi::Entities::OtherReportListResponse
          }, detail: <<~DETAIL
            Query the paged list of other type reports, ordered by report created_at desc.
            Label/level can be passed optionally to filter by subject.
            查询 other 类型报告分页列表，按报告创建时间倒序。可选传 label/level 按仓库/社区过滤。
          DETAIL
          params do
            requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
            optional :label, type: String, desc: 'repo or project label(optional) / 仓库或项目标签(可选)', documentation: { param_type: 'body', example: 'OpenHarmony-TPC' }
            optional :level, type: String, desc: 'repo or community(optional, only used with label) / 层级(可选，需与 label 同传)', documentation: { param_type: 'body', example: 'community' }
            optional :name, type: String, desc: 'fuzzy filter by software name / 按软件名称模糊过滤(可选)', documentation: { param_type: 'body', example: 'ssl' }
            optional :status, type: String, desc: 'filter by metric status: progress, again_progress, success / 按指标状态过滤(可选)', documentation: { param_type: 'body', example: 'success' }
            optional :page, type: Integer, desc: 'page number(optional,default 1) / 页码(可选，默认 1)', default: 1, documentation: { param_type: 'body', example: 1 }
            optional :per, type: Integer, desc: 'per page number(optional,default 10) / 每页数量(可选，默认 10)', default: 10, documentation: { param_type: 'body', example: 10 }
          end
          post :query_report_list do
            items = TpcSoftwareOtherReport.joins(:tpc_software_report_metrics)
                                          .where("tpc_software_report_metrics.version = ?",
                                                 TpcSoftwareReportMetric::Version_Default)
            if params[:label].present?
              label = ShortenedLabel.normalize_label(params[:label])
              level = params[:level].presence || 'repo'
              subject = Subject.find_by(label: label, level: level)
              items = subject.present? ? items.where(tpc_software_other_reports: { subject_id: subject.id }) : items.none
            end
            items = items.where("tpc_software_other_reports.name LIKE ?", "%#{params[:name]}%") if params[:name].present?
            items = items.where("tpc_software_report_metrics.status = ?", params[:status]) if params[:status].present?
            items = items.order("tpc_software_other_reports.created_at desc")

            pagyer, records = pagy(items, { page: params[:page], items: params[:per] })
            { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page,
              items: Openapi::Entities::OtherReportItem.represent(records) }
          end

        end

      end
    end
  end
end
