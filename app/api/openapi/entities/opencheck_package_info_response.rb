# frozen_string_literal: true
module Openapi
  module Entities

    class PackageInfoItem < Grape::Entity
      expose :code_count, documentation: { type: 'int', desc: 'code_count', example: 23 }
      expose :description, documentation: { type: 'String', desc: 'description' }
      expose :home_url, documentation: { type: 'String', desc: 'home_url' }
      expose :dependent_count, documentation: { type: 'int', desc: 'dependent_count', example: 23 }
      expose :down_count, documentation: { type: 'int', desc: 'down_count', example: 23 }
      expose :day_enter, documentation: { type: 'String', desc: 'day_enter' }
    end

    class OpencheckPackageInfoResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'count / 总数', example: 100 }
      expose :items, using: Entities::PackageInfoItem, documentation: { type: 'Entities::PackageInfoItem', desc: 'response',
                                                                        param_type: 'body', is_array: true }
    end
  end
end
