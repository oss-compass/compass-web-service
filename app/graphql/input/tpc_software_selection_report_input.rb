# frozen_string_literal: true

module Input
  class TpcSoftwareSelectionReportInput < Types::BaseInputObject
    argument :name, String, required: true
    argument :tpc_software_sig_id, Integer, required: true
    argument :code_url, String, required: true
    argument :programming_language, String, required: true
    argument :vulnerability_response, String, required: true
    argument :adaptation_method, String, required: true
    argument :architecture_diagrams, [Input::Base64ImageInput], required: false
    argument :oh_commit_sha, String, required: true
    argument :upstream_collaboration_strategy, Integer, required: true
    argument :upstream_communication_link, String, required: true
    argument :report_category, Integer, required: false
  end
end
