# frozen_string_literal: true

module Types
  module Queries
    class UserSearchQuery < BaseQuery
      type [Types::UserType], null: false
      description 'Fuzzy search by mailbox and name'
      argument :keyword, String, required: true, description: 'search keyword'

      def resolve(keyword: nil)
        login_required!(context[:current_user])

        User.joins(:login_binds)
            .where("users.email LIKE :search
                    OR users.name LIKE :search
                    OR login_binds.account LIKE :search
                    OR login_binds.nickname LIKE :search", search: "%#{keyword}%")
      end
    end
  end
end
