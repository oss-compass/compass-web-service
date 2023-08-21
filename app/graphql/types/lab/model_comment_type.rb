# frozen_string_literal: true

module Types
  module Lab
    class ModelCommentType < Types::BaseObject
      field :id, Integer, null: false
      field :content, String, null: false
      field :model, ModelDetailType, null: false
      field :user, Types::SimpleUserType, null: false
      field :parent, ModelCommentType
      field :metric, ModelMetricType
      field :images, [Types::ImageType]
      field :replies, [ModelCommentType]
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
