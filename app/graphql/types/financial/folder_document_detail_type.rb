# frozen_string_literal: true

module Types
  module Financial
    class FolderDocumentDetailType < BaseObject

      field :repo_url, String, null: true
      field :folder_document_details, DocumentDetailType, null: true

    end
  end
end
