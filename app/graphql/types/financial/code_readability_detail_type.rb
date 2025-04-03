# frozen_string_literal: true

module Types
  module Financial
    class CodeReadabilityDetailType < BaseObject
      field :repo_url, String, null: true
      field :evaluate_code_readability, [EvaluateCodeReadabilityType], null: true
    end
  end
end
