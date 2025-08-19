# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricClarificationPermissionType < Types::BaseObject
      field :clarification_committer_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :clarification_sig_lead_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :clarification_legal_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :clarification_compliance_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :clarification_community_collaboration_wg_permission, Integer, description: '1: permissioned, 0: unpermissioned'
    end
  end
end
