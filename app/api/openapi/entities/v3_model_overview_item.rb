# frozen_string_literal: true

module Openapi
  module Entities
    class V3ModelOverviewItem < OverviewItem
      expose :score, documentation: { type: 'Float', desc: 'Main score alias / 模型主分（与 main_score 一致）', example: 0.03919 }
    end
  end
end
