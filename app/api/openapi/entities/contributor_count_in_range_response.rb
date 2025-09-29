# frozen_string_literal: true
module Openapi
  module Entities

  
    class ContributorCountInRangeResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Count of Contributors / 贡献者数量', example: 100 }
    end

  end
end
