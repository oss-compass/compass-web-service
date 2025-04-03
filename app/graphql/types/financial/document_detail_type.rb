# frozen_string_literal: true

module Types
  module Financial
    class DocumentDetailType < BaseObject

      field :doc_number, Integer, null: true
      field :folder_document_details, [DocDetailType], null: true

    end
  end
end
