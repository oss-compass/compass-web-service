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
    mount Openapi::V2::L1::RepoLanguage
    mount Openapi::V2::L1::Releases
    mount Openapi::V2::L1::Opencheck
    # L2
    mount Openapi::V2::L2::ContributorPortrait
    mount Openapi::V2::L2::CommunityPortrait
    mount Openapi::V2::L2::SoftwareArtifactPortrait
    mount Openapi::V2::L2::TopOrgContributors
    # L3
    mount Openapi::V2::L3::ModelCodequality
    mount Openapi::V2::L3::ModelCommunity
    mount Openapi::V2::L3::ModelActivity
    mount Openapi::V2::L3::ModelGroupActivity
    mount Openapi::V2::L3::ModelDomainPersona
    mount Openapi::V2::L3::ModelRolePersona
    mount Openapi::V2::L3::ModelMilestonePersona
    mount Openapi::V2::L3::ModelOpencheck
    mount Openapi::V2::L3::ModelCriticalityScore
    mount Openapi::V2::L3::ModelScorecard
    mount Openapi::V2::L3::ModelCiiBestBadge
    mount Openapi::V2::L3::ModelOverview
    mount Openapi::V2::FinanceStandard
    mount Openapi::V2::ThirdSoftwareSelection
    mount Openapi::V2::Auth
    mount Openapi::V2::TrackEvent
    mount Openapi::V2::Admin

    mount Openapi::V2::Server::SystemServer
    mount Openapi::V2::Server::ProjectServer
    mount Openapi::V2::Server::QueueServer
    mount Openapi::V2::FeedbackModule
    mount Openapi::V2::Star::StarProjectServer

    mount Openapi::V3::CommunityHealth::CollaborationEfficiency::ResponseTimeliness
    mount Openapi::V3::CommunityHealth::CollaborationEfficiency::CollaborationQuality
    mount Openapi::V3::CommunityHealth::CommunityVitality::CommunityPopularity
    mount Openapi::V3::CommunityHealth::CommunityVitality::ContributionActivity
    mount Openapi::V3::CommunityHealth::CommunityVitality::DeveloperBase
    mount Openapi::V3::CommunityHealth::DevelopmentGovernance::OrganizationalGovernance
    mount Openapi::V3::CommunityHealth::DevelopmentGovernance::PersonalGovernance

    mount Openapi::V3::DeveloperJourney::DeveloperAttraction::DeveloperAttraction
    mount Openapi::V3::DeveloperJourney::DeveloperGrowth::ParticipationTier
    mount Openapi::V3::DeveloperJourney::DeveloperGrowth::DeveloperPromotion
    mount Openapi::V3::DeveloperJourney::DeveloperRetention::CoreRetention
    mount Openapi::V3::DeveloperJourney::DeveloperRetention::CoreChurn
    mount Openapi::V3::DeveloperJourney::DeveloperRetention::CoreLoss

    mount Openapi::V3::SupplyChainSecurity::SourceManagement::LegalCompliance
    mount Openapi::V3::SupplyChainSecurity::SourceManagement::SecurityManagement
    mount Openapi::V3::SupplyChainSecurity::ReleaseAndMaintenance::ReleaseQuality
    mount Openapi::V3::SupplyChainSecurity::ReleaseAndMaintenance::MaintenanceManagement
    mount Openapi::V3::SupplyChainSecurity::DevAndBuild::CodeReviewQuality
    mount Openapi::V3::SupplyChainSecurity::DevAndBuild::DevelopmentDocumentQuality
    mount Openapi::V3::SupplyChainSecurity::DevAndBuild::TrustedBuild

    mount Openapi::V3::ModelScore

    mount Openapi::CompassController::DashboardController
    mount Openapi::CompassController::MetricsModelController

    add_swagger_documentation \
      doc_version: '2.0.0',
      mount_path: '/api/v2/docs',
      add_version: true,
      info: {
        title: 'Compass OpenAPI',
        description: 'The API is still in frequent development stage, the interface parameters are not stabilized, please use with caution!',
        contact_url: ENV.fetch('DEFAULT_HOST')
      },

      # tags: [
      #   { name: 'Metadata / 元数据', description: 'Operations about Metadata',
      #     second_names: [] },
      #   { name: 'Metrics Data / 指标数据', description: 'Operations about Metrics Data',
      #     second_names: ['Contributor Persona / 开发者画像', 'Community Persona / 社区画像', 'Software Artifact Persona / 软件制品画像'] },
      #   { name: 'Metrics Model Data / 模型数据', description: 'Operations about Metrics Model Data',
      #     second_names: [] },
      #   {
      #     name: 'Scene Invocation / 场景调用', description: 'Operations about Scene Invocation',
      #     second_names: []
      #   },
      #   {
      #     name: 'Community Ecosystem Health / 社区生态健康评估',
      #     second_names: [
      #       'Collaboration Efficiency / 协作效率',
      #       'Community Vitality / 社区活力',
      #       'Ecosystem Impact / 生态影响力',
      #       'Development Governance / 开放治理'
      #     ]
      #   },
      #   {
      #     name: 'Developer Journey / 开发者旅程评估',
      #     second_names: [
      #       'Developer Attraction / 开发者吸引',
      #       'Developer Growth / 开发者成长',
      #       'Developer Retention / 开发者留存',
      #     ]
      #   },
      #   {
      #     name: 'Opensource Software Supply Chain Security / 开源软件供应链安全评估',
      #     second_names: [
      #       'Source Management / 源码管理',
      #       'Dev and Build / 开发与构建',
      #       'Release and Maintenance / 发布与维护',
      #     ]
      #   }
      # ],

     tags: [
  {
    "name": "V2 API",
    "description": "Version 2 Endpoints",
    "children": [
      {
        "name": "Metadata / 元数据",
        "description": "Operations about Metadata",
        "children": []
      },
      {
        "name": "Metrics Data / 指标数据",
        "description": "Operations about Metrics Data",
        "children": [
          { "name": "Contributor Persona / 开发者画像", "description": "Operations about Contributor Persona" },
          { "name": "Community Persona / 社区画像", "description": "Operations about Community Persona" },
          { "name": "Software Artifact Persona / 软件制品画像", "description": "Operations about Software Artifact Persona" }
        ]
      },
      {
        "name": "Metrics Model Data / 模型数据",
        "description": "Operations about Metrics Model Data",
        "children": []
      },
      {
        "name": "Scene Invocation / 场景调用",
        "description": "Operations about Scene Invocation",
        "children": []
      }
    ]
  },
  {
    "name": "V3 API",
    "description": "Version 3 Endpoints",
    "children": [
      {
        "name": "Metrics / 度量指标",
        "description": "Operations about Metrics",
        "children": [
          { "name": "Community Ecosystem Health / 社区生态健康评估", "description": "Operations about Community Ecosystem Health" },
          { "name": "Developer Journey / 开发者旅程评估", "description": "Operations about Developer Journey" },
          { "name": "Opensource Software Supply Chain Security / 开源软件供应链安全评估", "description": "Operations about Opensource Software Supply Chain Security" }
        ]
      },
      {
        "name": "Evaluation Model / 评估模型",
        "description": "Operations about Evaluation Model",
        "children": [
          {
            "name": "Community Ecosystem Health / 社区生态健康评估",
            "description": "Operations about Community Ecosystem Health Model",
            "children": [
              {
                "name": "Collaboration Efficiency / 协作效率",
                "description": "Operations about Collaboration Efficiency Model",
                "children": [
                  { "name": "Response Timeliness / 响应及时性", "description": "Operations about Response Timeliness Model" },
                  { "name": "Collaboration Quality / 协作开发质量", "description": "Operations about Collaboration Quality Model" }
                ]
              },
              {
                "name": "Community Vitality / 社区活力",
                "description": "Operations about Community Vitality Model",
                "children": [
                  { "name": "Community Popularity / 社区流行度", "description": "Operations about Community Popularity Model" },
                  { "name": "Contribution Activity / 贡献活跃度", "description": "Operations about Contribution Activity Model" },
                  { "name": "Developer Base / 开发者基数", "description": "Operations about Developer Base Model" }
                ]
              },
              {
                "name": "Development Governance / 开放治理",
                "description": "Operations about Development Governance Model",
                "children": [
                  { "name": "Organizational Governance / 组织开放治理", "description": "Operations about Organizational Governance Model" },
                  { "name": "Personal Governance / 个人开放治理", "description": "Operations about Personal Governance Model" }
                ]
              }
            ]
          },
          {
            "name": "Developer Journey / 开发者旅程评估",
            "description": "Operations about Developer Journey Model",
            "children": [
              {
                "name": "Developer Attraction / 开发者吸引",
                "description": "Operations about Developer Attraction Model",
                "children": []
              },
              {
                "name": "Developer Growth / 开发者成长",
                "description": "Operations about Developer Growth Model",
                "children": [
                  { "name": "Participation Tier / 开发者参与度分层", "description": "Operations about Participation Tier Model" },
                  { "name": "Developer Promotion / 开发者晋升", "description": "Operations about Developer Promotion Model" }
                ]
              },
              {
                "name": "Developer Retention / 开发者留存",
                "description": "Operations about Developer Retention Model",
                "children": [
                  { "name": "Core Retention / 核心开发者留存率", "description": "Operations about Core Retention Model" },
                  { "name": "Core Churn / 核心开发者淡出率", "description": "Operations about Core Churn Model" },
                  { "name": "Core Loss / 核心开发者流失率", "description": "Operations about Core Loss Model" }
                ]
              }
            ]
          },
          {
            "name": "Opensource Software Supply Chain Security / 开源软件供应链安全评估",
            "description": "Operations about Opensource Software Supply Chain Security Model",
            "children": [
              {
                "name": "Source Management / 源码管理",
                "description": "Operations about Source Management Model",
                "children": [
                  { "name": "Legal Compliance / 合法合规", "description": "Operations about Legal Compliance Model" },
                  { "name": "Security Management / 安全管理", "description": "Operations about Security Management Model" }
                ]
              },
              {
                "name": "Release and Maintenance / 发布与维护",
                "description": "Operations about Release and Maintenance Model",
                "children": [
                  { "name": "Release Quality / 发布质量", "description": "Operations about Release Quality Model" },
                  { "name": "Maintenance Management / 维护管理", "description": "Operations about Maintenance Management Model" }
                ]
              },
              {
                "name": "Dev and Build / 开发与构建",
                "description": "Operations about Dev and Build Model",
                "children": [
                  { "name": "Code Review Quality / 代码审查质量", "description": "Operations about Code Review Quality Model" },
                  { "name": "Development Document Quality / 开发文档质量", "description": "Operations about Development Document Quality Model" },
                  { "name": "Trusted Build / 可信构建", "description": "Operations about Trusted Build Model" }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
],

      array_use_braces: true
  end
end
