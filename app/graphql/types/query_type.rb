module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :repo, resolver: Queries::RepoQuery
    field :overview, resolver: Queries::OverviewQuery
    field :metric_activity, resolver: Queries::ActivityMetricQuery
    field :metric_community, resolver: Queries::CommunityMetricQuery
    field :metric_codequality, resolver: Queries::CodequalityMetricQuery
  end
end
