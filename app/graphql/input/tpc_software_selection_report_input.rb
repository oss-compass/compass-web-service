# frozen_string_literal: true

module Input
  class TpcSoftwareSelectionReportInput < Types::BaseInputObject
    argument :name, String, required: true
    argument :tpc_software_sig_id, Integer, required: true
    argument :manufacturer, String, required: true
    argument :website_url, String, required: true
    argument :code_url, String, required: true
    argument :programming_language, String, required: true
    argument :vulnerability_disclosure, String, required: false
    argument :vulnerability_response, String, required: true
    argument :is_same_type_check, Integer, required: true
    argument :same_type_software_name, String, required: false
  end
end
