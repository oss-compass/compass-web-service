# frozen_string_literal: true

module Input
  class TpcSoftwareSelectionReportUpdateInput < Types::BaseInputObject
    argument :name, String, required: true
    argument :tpc_software_sig_id, Integer, required: true
    argument :programming_language, String, required: true
    argument :vulnerability_response, String, required: true
    argument :adaptation_method, String, required: true
  end
end
