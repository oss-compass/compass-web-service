# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorMonthlyResponse < Grape::Entity
      expose :date, documentation: { type: 'String', desc: 'date / 日期', example: '2025-01-31' }
      expose :value, documentation: { type: 'int', desc: 'value / 数量', example: 3 }

    end

  end
end
