# frozen_string_literal: true

module Types
  module Financial
    class FileDetailType < BaseObject

      field :name, String, null: true
      field :path, String, null: true

    end
  end
end
