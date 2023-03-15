module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :analysis_status, resolver: Queries::AnalysisStatusQuery
    field :fuzzy_search, resolver: Queries::ProjectFuzzyQuery
    field :recent_updates, resolver: Queries::ProjectRecentUpdatesQuery
    field :overview, resolver: Queries::OverviewQuery
    field :trending, resolver: Queries::TrendingQuery
    field :community_overview, resolver: Queries::CommunityOverviewQuery
    field :bulk_overview, resolver: Queries::BulkOverviewQuery

    field :metric_activity, resolver: Queries::ActivityMetricQuery
    field :metric_community, resolver: Queries::CommunityMetricQuery
    field :metric_codequality, resolver: Queries::CodequalityMetricQuery
    field :metric_group_activity, resolver: Queries::GroupActivityMetricQuery

    field :summary_activity, resolver: Queries::ActivitySummaryQuery
    field :summary_community, resolver: Queries::CommunitySummaryQuery
    field :summary_codequality, resolver: Queries::CodequalitySummaryQuery
    field :summary_group_activity, resolver: Queries::GroupActivitySummaryQuery

    field :latest_metrics, resolver: Queries::LatestMetricsQuery
    field :beta_metrics_index, resolver: Queries::BetaMetricsIndexQuery
    field :beta_metric_overview, resolver: Queries::BetaMetricOverviewQuery

    field :collection_hottest, resolver: Queries::CollectionHottestQuery
    # field :collection_detail, resolver: Queries::Collections::CollectionDetailQuery
    # field :collection_overview, resolver: Queries::Collections::CollectionOverviewQuery

    # field :keyword_overview, resolver: Queries::Keywords::KeywordOverviewQuery
  end
end
