# frozen_string_literal: true

module Types
  module Financial
    class ProjectVersionModelDetailType < Types::BaseObject
      field :uuid, String, null: false
      field :label, String, null: false
      field :version_number, String, null: false

      # license_commercial_allowed
      field :license_list, [String], null: true
      field :license_commercial_allowed, Integer, null: true
      field :non_commercial_licenses, [String], null: true
      field :license_commercial_allowed_details, String, null: true

      # license_change_claims_required
      field :license_change_claims_required, Integer, null: true
      field :licenses_requiring_claims, [String], null: true
      field :license_change_claims_required_details, String, null: true

      # license_is_weak
      field :license_is_weak, Integer, null: true
      field :license_is_weak_details, String, null: true

      # license_conflicts_exist
      field :license_conflicts_exist, Integer, null: true

      # license_dep_conflicts_exist
      field :license_dep_conflicts_exist, Integer, null: true
      field :license_dep_conflicts_exist_status, String, null: true
      field :license_dep_conflicts_exist_details, String, null: true
      field :osi_license_list, [String], null: true
      field :non_osi_licenses, [String], null: true

      # activity_quarterly_contribution
      field :activity_quarterly_contribution, [Integer], null: true
      field :activity_quarterly_contribution_bot, [Integer], null: true
      field :activity_quarterly_contribution_without_bot, [Integer], null: true

      # security_vul_stat
      field :security_vul_stat, Integer, null: true
      field :security_vul_stat_info, String, null: true

      # security_vul_fixed
      field :security_vul_fixed, Integer, null: true
      field :security_vul_unfixed, Integer, null: true
      field :security_vul_fixed_info, String, null: true

      # security_vul_fixed
      field :security_scanned, Integer, null: true
      field :scanner, String, null: true
      field :security_scanned_info, String, null: true

      # org_contribution
      field :org_contribution, Integer, null: true
      field :org_contribution_details, [OrgContributionDetailType], null: true

      # doc_number
      field :doc_number, Integer, null: true
      field :folder_document_details, [FolderDocumentDetailType], null: true

      # doc_quarty
      field :doc_quarty, Integer, null: true
      field :doc_quarty_details, [DocQuartyDetailType], null: true
      #
      # zh_files_number
      field :zh_files_number, Integer, null: true
      field :zh_files_details, [ZhFileDetailType], null: true

      # vul_levels
      field :vul_levels, Integer, null: true
      field :vul_level_details, [VulLevelDetailType], null: true

      # vul_detect_time
      field :vul_detect_time, Integer, null: true
      field :vul_detect_time_details, [VulDetectTimeDetailType], null: true

      # vulnerablity_feedback_channels
      field :vulnerablity_feedback_channels, Integer, null: true
      field :vulnerablity_feedback_channels_details, [VulnerablityFeedbackChannelDetailType], null: true
      #
      # code_readability
      field :code_readability, Integer, null: true
      field :code_readability_detail, [CodeReadabilityDetailType], null: true

      # field :created_at, GraphQL::Types::ISO8601DateTime

    end
  end
end
