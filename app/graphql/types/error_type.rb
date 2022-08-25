module Types
  class ErrorType < Types::BaseObject
    field :message, String, null: true, description: '错误信息'
    field :path, [String], null: true, description: '错误路径'
  end
end
