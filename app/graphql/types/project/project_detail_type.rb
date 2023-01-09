# frozen_string_literal: true

module Types
  module Project
    class ProjectDetailType < Types::BaseObject
      field :label, String
      field :keywords, [Types::Keyword::KeywordType]
    end
  end
end
