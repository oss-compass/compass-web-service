# frozen_string_literal: true

module Types
  module Financial
    class DocQuartyDetailType < BaseObject

      field :repo_url, String, null: true
      field :doc_quarty_details, QuartyDetailType, null: true

    end
  end
end
