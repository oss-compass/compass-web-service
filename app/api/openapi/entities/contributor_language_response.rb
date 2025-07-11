# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorLanguageResponse < Grape::Entity
      expose :language, documentation: {
        type: String, desc: 'Programming Language / 编程语言', example: 'Python'
      }
      expose :ratio, documentation: {
        type: Float, desc: 'Language Contribution Ratio (0~1) / 该语言的贡献占比（0~1之间）', example: 0.4567
      }
    end

  end
end
