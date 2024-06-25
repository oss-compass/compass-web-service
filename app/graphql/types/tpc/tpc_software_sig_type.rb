# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSigType < Types::BaseObject
      field :id, Integer, null: false
      field :name, String, null: false
      field :description, String, null: false
    end
  end
end
