# frozen_string_literal: true

module Types
  module Financial
    class QuartyDocDetailType < BaseObject

      field :name, String, null: true

      field :path, String, null: true
      field :Word_count, Integer, null: true
      field :Picture_count, PictureCountDetailType, null: true


    end
  end
end
