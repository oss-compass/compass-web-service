# frozen_string_literal: true

require 'grape-swagger'

module Openapi
  class Base < Grape::API
    helpers Openapi::V1::Helpers

    mount Openapi::V1::Subject
    mount Openapi::V1::Contributor
    mount Openapi::V1::MetricModel
    mount Openapi::V1::AnalysisTask

    add_swagger_documentation \
      doc_version: '0.0.2',
    mount_path: '/api/v1/docs',
    add_version: true,
    info: {
      title: 'Compass OpenAPI',
      description: 'The API is still in frequent development stage, the interface parameters are not stabilized, please use with caution!',
      contact_url: ENV.fetch('DEFAULT_HOST')
    },
    array_use_braces: true
  end
end
