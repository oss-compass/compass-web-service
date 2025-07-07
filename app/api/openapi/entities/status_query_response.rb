# frozen_string_literal: true
module Openapi
  module Entities

    class StatusQueryResponse < Grape::Entity
      expose :trigger_status, documentation: { type: 'String', desc: 'status / 状态', example: 'pending' }
    end

  end
end
