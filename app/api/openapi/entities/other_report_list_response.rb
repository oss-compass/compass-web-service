# frozen_string_literal: true
module Openapi
  module Entities

    class OtherReportItem < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: 'report id / 报告 id', example: 1 }
      expose :report_type, documentation: { type: 'Integer', desc: 'report type / 报告类型', example: 0 }
      expose :short_code, documentation: { type: 'String', desc: 'report short code / 报告短码', example: 'o1a2b3c4d' }
      expose :name, documentation: { type: 'String', desc: 'software name / 软件名称', example: 'openssl' }
      expose :tpc_software_sig_id, documentation: { type: 'Integer', desc: 'tpc software sig id / 所属 SIG id', example: 1 }
      expose :sig_name, documentation: { type: 'String', desc: 'sig name / SIG 名称', example: 'sig-openssl' }
      expose :code_url, documentation: { type: 'String', desc: 'code url / 源码地址', example: 'https://gitee.com/src-openeuler/openssl' }
      expose :programming_language, documentation: { type: 'String', desc: 'programming language / 编程语言', example: 'C' }
      expose :manufacturer, documentation: { type: 'String', desc: 'manufacturer / 厂商' }
      expose :website_url, documentation: { type: 'String', desc: 'website url / 官网地址' }
      expose :license, documentation: { type: 'String', desc: 'license / 许可证', example: 'Apache-2.0' }
      expose :code_count, documentation: { type: 'Integer', desc: 'code count / 代码行数' }
      expose :vulnerability_response, documentation: { type: 'String', desc: 'vulnerability response / 漏洞响应方式' }
      expose :adaptation_method, documentation: { type: 'String', desc: 'adaptation method / 适配方式' }
      expose :upstream_collaboration_strategy, documentation: { type: 'Integer', desc: 'upstream collaboration strategy / 上游协作策略' }
      expose :upstream_communication_link, documentation: { type: 'String', desc: 'upstream communication link / 上游沟通链接' }
      expose :report_category, documentation: { type: 'Integer', desc: '报告分类 / report category' }
      expose :user_id, documentation: { type: 'Integer', desc: 'creator user id / 创建人用户 id', example: 1 }
      expose :user_name, documentation: { type: 'String', desc: 'creator user name / 创建人用户名', example: 'lisongnan' }
      expose :created_at, documentation: { type: 'String', desc: 'created at / 创建时间', example: '2026-11-26T15:00:00Z' }
      expose :updated_at, documentation: { type: 'String', desc: 'updated at / 更新时间', example: '2026-11-26T15:00:00Z' }
      expose :metric, documentation: { type: 'JSON', desc: 'report metric(default version) / 报告指标(默认版本): {status, updated_at}' } do |report|
        metric = report.tpc_software_report_metrics.where(version: TpcSoftwareReportMetric::Version_Default).first
        metric.present? ? { status: metric.status, updated_at: metric.updated_at } : nil
      end

      private

      def sig_name
        TpcSoftwareSig.find_by(id: object.tpc_software_sig_id)&.name
      end

      def user_name
        User.find_by(id: object.user_id)&.name
      end
    end

    class OtherReportListResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'total count / 总数', example: 1 }
      expose :total_page, documentation: { type: 'Integer', desc: 'total page / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'current page / 当前页', example: 1 }
      expose :items, using: Entities::OtherReportItem, documentation: { type: 'Entities::OtherReportItem', desc: 'report items / 报告列表', is_array: true, param_type: 'body' }
    end

  end
end
