# frozen_string_literal: true
module Openapi
  module Entities

    class LanguageItem < Grape::Entity
      expose :language, documentation: { type: 'String', desc: 'language', example: "ruby" }
    end

    class RepoLanguageResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'total page / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'current page / 当前页', example: 1 }
      expose :items, using: Entities::LanguageItem, documentation: { type: 'Entities::LanguageItem', desc: 'response',
                                                                     param_type: 'body', is_array: true }
    end
  end
end
