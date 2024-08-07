# frozen_string_literal: true

module Input
  class TpcSoftwareGraduationReportUpdateInput < Types::BaseInputObject
    argument :name, String, required: true
    argument :tpc_software_sig_id, Integer, required: true
    argument :upstream_code_url, String, required: false
    argument :programming_language, String, required: true
    argument :adaptation_method, String, required: true
    argument :lifecycle_policy, String, required: true
    argument :round_upstream, String, required: false
    argument :is_incubation, Integer, required: true
  end
end
