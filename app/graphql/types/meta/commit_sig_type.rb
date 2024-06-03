# frozen_string_literal: true

module Types
  module Meta
    class CommitSigType < Types::BaseObject
      field :sig_name, String
      field :lines_added, Integer
      field :lines_removed, Integer
      field :lines_changed, Integer
    end
  end
end
