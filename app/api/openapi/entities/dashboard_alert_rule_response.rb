# frozen_string_literal: true
module Openapi
  module Entities

    class DashboardAlertRuleResponse < Grape::Entity
      expose :success, documentation: { type: 'Boolean', desc: '操作是否成功', example: true }
    end

  end
end
