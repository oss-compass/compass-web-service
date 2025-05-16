# frozen_string_literal: true
module Openapi
  module Entities

    class ContributionType < Grape::Entity
      expose :contribution_type, documentation: { type: 'String', desc: 'contribution_type', example: "code_author" }
      expose :code_contribution, documentation: { type: 'int', desc: 'contribution', example: 16 }
    end

    class ContributorItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "1d15313d8aa3373cde43485978c974a7b136956c" }
      expose :contributor, documentation: { type: 'String', desc: 'contributor', example: "fred-wang" }
      expose :contribution, documentation: { type: 'Integer', desc: 'contribution', example: 16 }
      expose :contribution_without_observe, documentation: { type: 'Integer', desc: 'contribution_without_observe', example: 16 }
      expose :ecological_type, documentation: { type: 'String', desc: 'ecological_type', example: "individual participant" }
      expose :organization, documentation: { type: 'String', desc: 'organization', example: '' }
      expose :contribution_type_list, using: Entities::ContributionType,
             documentation: { type: ' Entities::ContributionType', desc: 'contribution_type_list', is_array: true }
      expose :is_bot, documentation: { type: 'Boolean', desc: 'is_bot', example: false }
      expose :repo_name, documentation: { type: 'String', desc: 'repo_name', example: "https://github.com/mathjax/MathJax" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2010-08-02T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-06T06:56:26.153196+00:00" }

    end

    class ContributorResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: '总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: '总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: '当前页', example: 1 }
      expose :items, using: Entities::ContributorItem, documentation: { type: 'Entities::ContributorItem', desc: 'response',
                                                                        param_type: 'body', is_array: true }
    end

  end
end



