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
        { name: 'Metadata', description: 'Operations about L1 Metadata',
          second_names: [] },
        { name: 'L2 Portrait/Metric data', description: 'Operations about L2 Portrait/Metric data',
          second_names: ['Contributor Portrait', 'Community Portrait', 'Software Artifact Portrait'] },
        { name: 'Metric model data', description: 'Operations about L3 Evaluate model data',
          second_names: [] },
        {
          name: 'Finance Standard Metric', description: 'Operations about Finance Standard Metric',
          second_names: []
        }
      ],
      array_use_braces: true
  end
end
