# frozen_string_literal: true

module Input
  class TpcSoftwareSelectionReportInput < Types::BaseInputObject
    argument :name, String, required: true
    argument :tpc_software_sig_id, Integer, required: true
    argument :release, String, required: false
    argument :release_time, GraphQL::Types::ISO8601DateTime
    argument :manufacturer, String, required: true
    argument :website_url, String, required: true
    argument :code_url, String, required: true
    argument :programming_language, String, required: true
    argument :vulnerability_disclosure, String, required: false
    argument :vulnerability_response, String, required: false
  end
end
