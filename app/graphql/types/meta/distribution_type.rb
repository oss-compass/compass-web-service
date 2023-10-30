# frozen_string_literal: true
module Types
  module Meta
    class DistributionType < Types::BaseObject
      field :sub_count, Integer
      field :sub_ratio, Float
      field :sub_name, String
      field :total_count, Integer
    end
  end
end
