# frozen_string_literal: true

module Types
  module Lab
    class MyReportType < BasePageObject
      field :items,[Types::Lab::MyModelVersionType]
    end
  end
end
