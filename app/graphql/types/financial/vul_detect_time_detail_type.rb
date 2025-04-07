# frozen_string_literal: true

module Types
  module Financial
    class VulDetectTimeDetailType < BaseObject

      field :repo_url, String, null: true

      field :vul_detect_time_details, Integer, null: true
      field :error, String, null: true
    end
  end
end
