# frozen_string_literal: true
module Openapi
  module Entities

    class RecommendTxtResponseItem < Grape::Entity
      expose :keywords_bm25_score, documentation: { type: 'float', desc: '', example: 0.07599088 }
      expose :keywords_embedding_score, documentation: { type: 'float', desc: '', example: 0.2138480118603702 }
      expose :package_id, documentation: { type: 'String', desc: 'Library name + source (the format is library name + @@@@&&@@@@ + source) / 库名+来源（格式为 库名+@@@@&&@@@@ + 来源）', example: 'format@@@@$$@@@@npm' }
      expose :score, documentation: { type: 'float', desc: 'Comprehensive score / 综合得分', example: 0.121449216969881 }
      expose :summary_bm25_score, documentation: { type: 'float', desc: '', example: 0.07599088 }
      expose :summary_embedding_score, documentation: { type: 'float', desc: '', example: 0.16981687 }
    end

    class RecommendTxtResponse < Grape::Entity
      expose :items, using: Entities::RecommendTxtResponseItem, documentation: { type: 'Entities::RecommendResponseItem', desc: 'response', param_type: 'body', is_array: true }
    end

  end
end
