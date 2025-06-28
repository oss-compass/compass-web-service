# frozen_string_literal: true

require 'grape-swagger'

module Openapi
  class Base < Grape::API
    helpers Openapi::V1::Helpers

    mount Openapi::V1::Pull
    mount Openapi::V1::Issue
    mount Openapi::V1::Subject
    mount Openapi::V1::Contributor
    mount Openapi::V1::MetricModel
    mount Openapi::V1::AnalysisTask

    # add_swagger_documentation \
    #   doc_version: '0.0.2',
    # mount_path: '/api/v1/docs',
    # add_version: true,
    # info: {
    #   title: 'Compass OpenAPI',
    #   description: 'The API is still in frequent development stage, the interface parameters are not stabilized, please use with caution!',
    #   contact_url: ENV.fetch('DEFAULT_HOST')
    # },
    # array_use_braces: true

    # L1
    mount Openapi::V2::L1::Pull
    mount Openapi::V2::L1::Issue
    mount Openapi::V2::L1::Event
    mount Openapi::V2::L1::Contributors
    mount Openapi::V2::L1::Fork
    mount Openapi::V2::L1::Git
    mount Openapi::V2::L1::Stargazer
    mount Openapi::V2::L1::Watch
    mount Openapi::V2::L1::Repo
    mount Openapi::V2::L1::Releases
    # L2
    mount Openapi::V2::L2::ContributorPortrait
    mount Openapi::V2::L2::CommunityPortrait
    mount Openapi::V2::L2::SoftwareArtifactPortrait
    # L3
    mount Openapi::V2::L3::ModelCodequality
    mount Openapi::V2::L3::ModelCommunity
    mount Openapi::V2::L3::ModelActivity
    mount Openapi::V2::L3::ModelGroupActivity
    mount Openapi::V2::L3::ModelDomainPersona
    mount Openapi::V2::L3::ModelRolePersona
    mount Openapi::V2::L3::ModelMilestonePersona
    mount Openapi::V2::L3::ModelOpencheck
    mount Openapi::V2::FinanceStandard
    mount Openapi::V2::Auth
    mount Openapi::V2::TrackEvent

    add_swagger_documentation \
      doc_version: '2.0.0',
      mount_path: '/api/v2/docs',
      add_version: true,
      info: {
        title: 'Compass OpenAPI',
        description: 'The API is still in frequent development stage, the interface parameters are not stabilized, please use with caution!',
        contact_url: ENV.fetch('DEFAULT_HOST')
      },
      tags: [
        { name: 'Metadata / 元数据', description: 'Operations about Metadata',
          second_names: [] },
        { name: 'Metrics Data / 指标数据', description: 'Operations about Metrics Data',
          second_names: ['Contributor Persona / 开发者画像', 'Community Persona / 社区画像', 'Software Artifact Persona / 软件制品画像'] },
        { name: 'Metrics Model Data / 模型数据', description: 'Operations about Metrics Model Data',
          second_names: [] },
        {
          name: 'Scene Invocation / 场景调用', description: 'Operations about Scene Invocation',
          second_names: []
        }
      ],
      array_use_braces: true
  end
end
