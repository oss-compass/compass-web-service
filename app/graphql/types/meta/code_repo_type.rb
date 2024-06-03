# frozen_string_literal: true

module Types
  module Meta
    class CodeRepoType < Types::BaseObject
      field :repo_attribute_type, String
      field :repo_name, String
      field :sig_name, String
      field :manager, String
      field :lines_total, Integer
      field :lines, Integer
      field :lines_chang, Integer
    end
  end
end
