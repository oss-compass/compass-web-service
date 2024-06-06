# frozen_string_literal: true

module Types
  module Meta
    class SubjectCustomizationType < Types::BaseObject
      field :name, String, null: false
      field :label, String, null: false
      field :level, String, null: false
    end
  end
end
