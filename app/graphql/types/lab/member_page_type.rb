# frozen_string_literal: true

module Types
  module Lab
    class MemberPageType < BasePageObject
      field :model, ModelDetailType
      field :items, [Types::Lab::LabMemberType]
    end
  end
end
