# frozen_string_literal: true

module Types
  module Financial
    class ZhFileType < BaseObject

      field :zh_files_number, Integer, null: true
      field :zh_files_details, [FileDetailType], null: true

      # field :zh_files_details, ZhFilesPathType, null: true

    end
  end
end
