# frozen_string_literal: true
module Openapi
  module Entities

    class RecommendVoteUpResponseItem < Grape::Entity
      expose :message, documentation: { type: 'String', desc: 'message', example: 'Vote up/down recorded successfully' }
    end

    class RecommendVoteUpResponse < Grape::Entity
      expose :data, using: Entities::RecommendVoteUpResponseItem, documentation: { type: 'Entities::RecommendResponseItem', desc: 'response', example: 'Vote up/down recorded successfully', param_type: 'body', is_array: true }
    end

  end
end
