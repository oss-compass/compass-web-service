# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorReposResponse < Grape::Entity
      expose :repo_url, documentation: {
        type: String, desc: '贡献的仓库地址', example: 'https://github.com/oss-compass/compass-web-service'
      }

      expose :contribution, documentation: {
        type: Integer, desc: '贡献值（累加）', example: 150
      }
    end

  end
end
