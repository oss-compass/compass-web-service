# frozen_string_literal: true

module Types
  module Lab
    class VulType < BaseObject

      field :vul_levels, Integer, null: true
      field :vul_level_details, [VulLevelDetailType], null: true

    end
  end
end
