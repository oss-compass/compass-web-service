# frozen_string_literal: true

module Types
  module Lab
    class InvitationPageType < BasePageObject
      field :items, [Types::Lab::LabInvitationType]
    end
  end
end
