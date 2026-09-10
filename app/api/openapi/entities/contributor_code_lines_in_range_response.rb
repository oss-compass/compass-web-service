# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorCodeLinesItem < Grape::Entity
      expose :contributor, documentation: { type: 'String', desc: 'Contributor name / 贡献者名称', example: 'beckyvb' }
      expose :author_email, documentation: { type: 'String', desc: 'Author email / 贡献者邮箱', example: 'beckyvanbussel@gmail.com' }
      expose :code_additions, documentation: { type: 'Integer', desc: 'Lines of code added / 代码增加行数', example: 11934 }
      expose :code_deletions, documentation: { type: 'Integer', desc: 'Lines of code deleted / 代码删除行数', example: 7691 }
      expose :code_lines, documentation: { type: 'Integer', desc: 'Lines of code changed (additions plus deletions) / 代码变更总行数 (增加行数加上删除行数)', example: 19625 }
    end

    class ContributorCodeLinesInRangeResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count / 总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages / 总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page / 当前页', example: 1 }
      expose :items, using: Entities::ContributorCodeLinesItem, documentation: { type: 'Entities::ContributorCodeLinesItem', desc: 'response',
                                                                                 param_type: 'body', is_array: true }
    end

  end
end
