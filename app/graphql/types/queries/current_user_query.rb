# frozen_string_literal: true
module Types
  module Queries
    class CurrentUserQuery < BaseQuery
      type UserType, null: true

      def resolve
        context[:current_user]
      end
    end
  end
end
