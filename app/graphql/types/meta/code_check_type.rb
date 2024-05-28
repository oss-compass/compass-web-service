# frozen_string_literal: true

module Types
  module Meta
    class CodeCheckType < Types::BaseObject
      field :user_login, String
      field :comment_num, Integer
      field :time_check_hours, Float
      field :lines_added, Integer
      field :lines_removed, Integer
    end
  end
end
