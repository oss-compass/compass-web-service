# frozen_string_literal: true

require 'grape-swagger'

module Openapi
 class Base < Grape::API
   mount Openapi::V1::RepoBelongsTo
   mount Openapi::V1::MetricModelsOverview

   add_swagger_documentation \
     doc_version: '0.0.1',
   mount_path: '/api/v1/docs',
   add_version: true,
   info: {
     title: 'Compass OpenAPI',
     contact_url: ENV.fetch('DEFAULT_HOST')
   },
   array_use_braces: true
 end
end
