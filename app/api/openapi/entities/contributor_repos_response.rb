# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorReposResponse < Grape::Entity
      expose :repo_url, documentation: {
        type: String, desc: 'Repo url / 贡献的仓库地址', example: 'https://github.com/oss-compass/compass-web-service'
      }

      expose :contribution, documentation: {
        type: Integer, desc: 'Contribution / 贡献值（累加）', example: 150
      }

      expose :roles, documentation: {
        type: String, is_array: true, desc: 'Role / 角色', example: ["individual_manager", "core"]
      }
    end

  end
end
