# frozen_string_literal: true

module Input
  class TpcSoftwareGraduationReportInput < Types::BaseInputObject
    argument :name, String, required: true
    argument :tpc_software_sig_id, Integer, required: true
    argument :code_url, String, required: true
    argument :upstream_code_url, String, required: false
    argument :programming_language, String, required: true
    argument :adaptation_method, String, required: true
    argument :lifecycle_policy, String, required: true
    argument :round_upstream, String, required: false
    argument :is_incubation, Integer, required: true
    argument :architecture_diagrams, [Input::Base64ImageInput], required: false
    argument :oh_commit_sha, String, required: true
  end
end
