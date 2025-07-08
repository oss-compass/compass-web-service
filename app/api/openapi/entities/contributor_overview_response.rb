# frozen_string_literal: true
module Openapi
  module Entities

    class ContributorOverviewResponse < Grape::Entity
      expose :avatar_url, documentation: { type: String, desc: 'GitHub Avatar URL / GitHub 头像 URL', example: 'https://avatars.githubusercontent.com/u/53640896?v=4' }
      expose :html_url, documentation: { type: String, desc: 'GitHub Profile URL / GitHub 用户主页链接', example: 'https://github.com/xxx' }
      expose :country, documentation: { type: String, desc: 'Country/Region / 国家/地区', example: '中国' }
      expose :city, documentation: { type: String, desc: 'City / 城市', example: '深圳市' }
      expose :company, documentation: { type: String, desc: 'Company / 公司', example: 'Huawei' }
      expose :main_language, documentation: { type: String, desc: 'Main Programming Language / 主要编程语言', example: 'Python' }
      expose :topic, documentation: { type: Array[String], desc: 'Topic List / 主题列表', example: ['graphql', 'rails', 'ruby', 'ruby-on-rails', 'metrics-model', 'open-source-health', 'openssf-scorecard', 'scorecard', 'docs'] }
      expose :core_project, documentation: { type: Array[String], desc: 'Core Project URL List / 核心项目 URL 列表', example: ['https://github.com/oss-compass/compass-metrics-model', 'https://github.com/oss-compass/compass-web-service'] }
      expose :manage_project, documentation: { type: Array[String], desc: 'Managed Project URL List / 管理项目 URL 列表', example: ['https://github.com/oss-compass/compass-web-service', 'https://github.com/oss-compass/compass-metrics-model', 'https://github.com/oss-compass/docs'] }

    end

  end
end
