# frozen_string_literal: true

module Types
  module Financial
    class VulLevelDetailType < BaseObject

      field :repo_url, String, null: true
      field :vul_level_details, VulLevelType, null: true

    end
  end
end
