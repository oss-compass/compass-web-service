# frozen_string_literal: true
module Openapi
  module Entities

    class OtherReportCreateResponse < Grape::Entity
      expose :status, documentation: { type: 'Boolean', desc: 'create status / 创建状态', example: true }
      expose :message, documentation: { type: 'String', desc: 'message / 提示信息', example: '' }
      expose :report_id, documentation: { type: 'Integer', desc: 'report id / 报告 id', example: 1 }
      expose :short_code, documentation: { type: 'String', desc: 'report short code / 报告短码', example: 's1a2b3c4d' }
    end

  end
end
