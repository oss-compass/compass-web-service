# frozen_string_literal: true

module Types
  module Financial
    class  PictureCountDetailType < BaseObject

      field :code_blocks, Integer, null: true
      field :images, Integer, null: true
      field :videos, Integer, null: true
      field :audios, Integer, null: true
      field :external_links, Integer, null: true

    end
  end
end
