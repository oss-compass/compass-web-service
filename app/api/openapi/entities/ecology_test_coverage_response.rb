# frozen_string_literal: true

module Openapi
  module Entities
    class EcologyTestCoverageItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: '58cd018b007ee61cebd92e9147fdd33d7bab3e93' }
      expose :level, documentation: { type: 'String', desc: 'level', example: 'repo' }
      expose :type, documentation: { type: 'NilClass', desc: 'type', example: nil }
      expose :label, documentation: { type: 'String', desc: 'label', example: 'https://github.com/ddragula/webgpu-ts-tests' }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: 'Code Review Quality' }
      expose :period, documentation: { type: 'String', desc: 'period', example: 'month' }
      expose :grimoire_creation_date,
             documentation: { type: 'String', desc: 'grimoire_creation_date', example: '2024-05-01T00:00:00+00:00' }

      expose :ecology_test_coverage,
             documentation: {
               type: 'Integer',
               desc: 'Test coverage score / 测试覆盖度分数',
               example: 0
             }

      expose :ecology_test_coverage_detail,
             documentation: {
               type: 'String',
               desc: 'Test coverage detail (JSON string) / 测试覆盖度详情（JSON字符串）',
               example: "{\"duplication_score\":0,\"duplication_ratio\":null,\"coverage_score\":0,\"coverage_ratio\":null}"
             }

      expose :test_coverage_percent,
             documentation: {
               type: 'Float',
               desc: 'Test coverage percent / 测试覆盖率（%）',
               example: nil,
               nullable: true
             }

      expose :ecology_test_coverage_raw,
             documentation: {
               type: 'String',
               desc: 'Raw coverage report (JSON string) / 覆盖率报告原始数据（JSON字符串）',
               example: "{\"component\":{\"key\":\"foo\",\"measures\":[]}}"
             }
    end

    class EcologyTestCoverageResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'Integer', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'Integer', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::EcologyTestCoverageItem,
             documentation: { type: 'Entities::EcologyTestCoverageItem', desc: 'response', param_type: 'body', is_array: true }
    end
  end
end

