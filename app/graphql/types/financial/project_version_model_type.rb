# frozen_string_literal: true

module Types
  module Financial
    class ProjectVersionModelType < BaseObject
      field :items, [Types::Financial::ProjectVersionModelDetailType]
    end
  end
end
