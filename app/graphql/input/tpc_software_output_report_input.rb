# frozen_string_literal: true

module Input
  class TpcSoftwareOutputReportInput < Types::BaseInputObject
    argument :name, String, required: true
    argument :tpc_software_selection_order_num, String, required: true
    argument :tpc_software_sig_id, Integer, required: true
    argument :repo_url, String, required: true
    argument :reason, String, required: true
  end
end
