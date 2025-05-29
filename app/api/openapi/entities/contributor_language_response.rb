# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorLanguageResponse < Grape::Entity
      expose :language, documentation: {
        type: String, desc: '编程语言', example: 'Python'
      }
      expose :ratio, documentation: {
        type: Float, desc: '该语言的贡献占比（0~1之间）', example: 0.4567
      }
    end

  end
end
