# frozen_string_literal: true

module Openapi
  module Entities
    class ResponseTimelinessModelDataItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :label, documentation: { type: 'String', desc: 'label' }
      expose :issue_new_unresponsive_ratio, documentation: { type: 'Float', desc: 'Issue new unresponsive ratio / Issue 未响应占比', nullable: true }
      expose :issue_new_first_response_avg, documentation: { type: 'Float', desc: 'Issue new first response avg / Issue 首次响应时间平均值', nullable: true }
      expose :issue_new_first_response_mid, documentation: { type: 'Float', desc: 'Issue new first response mid / Issue 首次响应时间中位数', nullable: true }
      expose :issue_new_handle_time_avg, documentation: { type: 'Float', desc: 'Issue new handle time avg / Issue 处理时长平均值', nullable: true }
      expose :issue_new_handle_time_mid, documentation: { type: 'Float', desc: 'Issue new handle time mid / Issue 处理时长中位数', nullable: true }
      expose :pr_unresponsive_rate, documentation: { type: 'Float', desc: 'PR unresponsive rate / PR 未响应占比', nullable: true }
      expose :pr_new_first_response_avg, documentation: { type: 'Float', desc: 'PR new first response avg / PR 首次响应时间平均值', nullable: true }
      expose :pr_new_first_response_mid, documentation: { type: 'Float', desc: 'PR new first response mid / PR 首次响应时间中位数', nullable: true }
      expose :pr_new_handle_time_avg, documentation: { type: 'Float', desc: 'PR new handle time avg / PR 处理时长平均值', nullable: true }
      expose :pr_new_handle_time_mid, documentation: { type: 'Float', desc: 'PR new handle time mid / PR 处理时长中位数', nullable: true }
      expose :score, documentation: { type: 'Float', desc: 'Score / 得分', nullable: true }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date' }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on' }
    end

    # Response Timeliness 「获取模型数据」列表：结构与 fetch_metric_data_v2 一致，items 含本模块全部指标字段及 score
    class ResponseTimelinessModelDataResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total count / 总数', example: 10 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total pages / 总页数', example: 1 }
      expose :page, documentation: { type: 'Integer', desc: 'Current page / 当前页', example: 1 }
      expose :items, using: Entities::ResponseTimelinessModelDataItem,
             documentation: { type: 'ResponseTimelinessModelDataItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end