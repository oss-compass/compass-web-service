module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :analysis_status, resolver: Queries::AnalysisStatusQuery
    field :fuzzy_search, resolver: Queries::ProjectFuzzyQuery
    field :overview, resolver: Queries::OverviewQuery
    field :community_overview, resolver: Queries::CommunityOverviewQuery

    field :metric_activity, resolver: Queries::ActivityMetricQuery
    field :metric_community, resolver: Queries::CommunityMetricQuery
    field :metric_codequality, resolver: Queries::CodequalityMetricQuery
    field :group_metric_activity, resolver: Queries::GroupActivityMetricQuery

    field :summary_activity, resolver: Queries::ActivitySummaryQuery
    field :summary_community, resolver: Queries::CommunitySummaryQuery
    field :summary_codequality, resolver: Queries::CodequalitySummaryQuery
    field :summary_group_activity, resolver: Queries::GroupActivitySummaryQuery

    field :latest_metrics, resolver: Queries::LatestMetricsQuery
  end
end
