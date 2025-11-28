# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareMemberType < Types::BaseObject
      field :id, Integer
      field :name, String
      field :email, String
      field :company, String
      field :github_account, String
      field :gitee_account, String
      field :gitcode_account, String
    end
  end
end
