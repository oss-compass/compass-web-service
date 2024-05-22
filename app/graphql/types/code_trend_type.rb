# frozen_string_literal: true

module Types
  class CodeTrendType < Types::BaseObject
    field :type, String
    field :detail_list, [Types::CodeTrendDetailType]
  end
end
