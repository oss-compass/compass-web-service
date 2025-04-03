# frozen_string_literal: true

module Types
  module Financial
    class ZhFileDetailType < BaseObject

      field :repo_url, String, null: true
      field :zh_files_details, ZhFileType, null: true

    end
  end
end
