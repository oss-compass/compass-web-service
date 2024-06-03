# frozen_string_literal: true

module Types
  class CodeTrendType < Types::BaseObject
    field :sig_name, String
    field :detail_list, [Types::CodeTrendDetailType]
  end
end
