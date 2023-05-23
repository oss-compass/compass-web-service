module Types
  class BaseConnection < Types::BaseObject
    # add `nodes` and `pageInfo` fields, as well as `edge_type(...)` and `node_nullable(...)` overrides
    include GraphQL::Types::Relay::ConnectionBehaviors

    field :total_count, Int, null: false

    def total_count
      return context[:connection_total_count] if context[:connection_total_count].present?

      return object.items.count if object.items.is_a?(Array)

      object.items&.unscope(:offset)&.count
    end
  end
end
