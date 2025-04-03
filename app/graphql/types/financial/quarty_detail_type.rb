# frozen_string_literal: true

module Types
  module Financial
    class QuartyDetailType < BaseObject

      field :doc_quarty, Integer, null: true

      field :doc_quarty_details, [QuartyDocDetailType], null: true


    end
  end
end
