# frozen_string_literal: true
module Openapi
  module Entities

    class TriggerResponse < Grape::Entity
 
      expose :status, documentation: { type: 'String', desc: 'status / 状态', example: 'pending' }
      expose :message, documentation: { type: 'String', desc: 'message / 信息', example: 'The submission has entered the analysis 
service queue, and we will synchronize the analysis report address under this Pull Request after the analysis is completed.' }

    end

  end
end
