# frozen_string_literal: true

module Types
  class BasePageObject < BaseObject
    field :count, Integer
    field :total_page, Integer
    field :page, Integer
  end
end
