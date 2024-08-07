# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionReportSearchType < Types::BaseObject
      field :id, Integer, null: false
      field :report_type, Integer, null: false
      field :name, String
      field :tpc_software_sig_id, Integer
      field :code_url, String
      field :programming_language, String
      field :adaptation_method, String
    end
  end
end
