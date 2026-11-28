# frozen_string_literal: true
module Openapi
  module Entities

    class RecommendVoteUpResponse < Grape::Entity
      expose :status, documentation: { type: 'Boolean', desc: 'Whether the vote was recorded / 是否记录成功', example: true }
      expose :message, documentation: { type: 'String', desc: 'Vote result message / 投票结果信息', example: 'Vote up recorded successfully' }
    end

  end
end
