# frozen_string_literal: true
module Openapi
  module Entities
    class TopContributorDistribution < Grape::Entity
      expose :subCount, documentation: { type: 'Integer', desc: 'subCount', example: 1 }
      expose :subRatio, documentation: { type: 'Float', desc: 'subRatio', example: 0.11 }
      expose :subName, documentation: { type: 'String', desc: 'subName' }
      expose :subBelong, documentation: { type: 'String', desc: 'subBelong' }
      expose :totalCount, documentation: { type: 'Integer', desc: 'totalCount', example: 1 }
    end

    class OrgContributorsDistribution < Grape::Entity
      expose :overviewName, documentation: { type: 'String', desc: 'overviewName' }
      expose :subTypeName, documentation: { type: 'String', desc: 'subTypeName' }
      expose :subTypePercentage, documentation: { type: 'Float', desc: 'subTypePercentage', example: 0.11 }
      expose :topContributorDistribution, using: Entities::TopContributorDistribution,
             documentation: { type: 'Entities::TopContributorDistribution', desc: 'response',
                              is_array: true }
    end

    class OrgItem < Grape::Entity
      expose :orgContributorsDistribution, using: Entities::OrgContributorsDistribution,
             documentation: { type: 'Entities::OrgContributorsDistribution', desc: 'response',
                              is_array: true }
    end

    class TopOrgContributorsResponse < Grape::Entity
      expose :count, documentation: { type: 'Integer', desc: 'count / 总数', example: 4 }
      expose :items, using: Entities::OrgItem,
             documentation: { type: 'Entities::OrgItem', desc: 'response',
                              is_array: true }
    end
  end
end
