# frozen_string_literal: true

module Types
  module Lab
    class MemberPageType < Types::BaseObject
      field :count, Integer
      field :total_page, Integer
      field :page, Integer
      field :model, ModelDetailType
      field :items, [Types::Lab::LabMemberType]
    end
  end
end
