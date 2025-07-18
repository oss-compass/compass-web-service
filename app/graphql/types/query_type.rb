module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :analysis_status, resolver: Queries::AnalysisStatusQuery
    field :analysis_status_verify, resolver: Queries::AnalysisStatusVerifyQuery

    field :fuzzy_search, resolver: Queries::ProjectFuzzyQuery
    field :org_fuzzy_search, resolver: Queries::OrgFuzzyQuery
    field :trending, resolver: Queries::TrendingQuery
    field :community_overview, resolver: Queries::CommunityOverviewQuery
    field :community_repos, resolver: Queries::CommunityReposQuery

    field :repo_belongs_to, resolver: Queries::RepoBelongsToQuery
    field :bulk_overview, resolver: Queries::BulkOverviewQuery
    field :bulk_shortened_label, resolver: Queries::BulkShortenedLabelQuery
    field :bulk_label_with_level, resolver: Queries::BulkLabelWithLevelQuery

    field :metric_activity, resolver: Queries::ActivityMetricQuery
    field :metric_community, resolver: Queries::CommunityMetricQuery
    field :metric_codequality, resolver: Queries::CodequalityMetricQuery
    field :metric_group_activity, resolver: Queries::GroupActivityMetricQuery

    field :metric_milestone_persona, resolver: Queries::MilestonePersonaMetricQuery
    field :metric_domain_persona, resolver: Queries::DomainPersonaMetricQuery
    field :metric_role_persona, resolver: Queries::RolePersonaMetricQuery

    ## Compass Lab Model Management
    field :custom_analysis_status, resolver: Queries::Lab::CustomAnalysisStatusQuery
    field :metric_set_overview, resolver: Queries::Lab::MetricSetOverviewQuery
    field :my_models, resolver: Queries::Lab::MyModelsQuery
    field :lab_model_detail, resolver: Queries::Lab::ModelDetailQuery
    field :lab_model_version, resolver: Queries::Lab::ModelVersionQuery
    field :lab_model_version_report_list, resolver: Queries::Lab::ModelVersionReportListQuery
    field :lab_model_version_report_detail, resolver: Queries::Lab::ModelVersionReportDetailQuery
    field :lab_model_comments, resolver: Queries::Lab::ModelCommentsQuery
    field :lab_model_comment_detail, resolver: Queries::Lab::ModelCommentDetailQuery
    field :lab_model_public_overview, resolver: Queries::Lab::ModelPublicOverviewQuery
    field :my_model_reports, resolver: Queries::Lab::MyModelReportsQuery
    field :reference_model_reports, resolver: Queries::Lab::ReferenceModelReportsQuery

    field :project_version_models_type, resolver: Queries::Lab::FinanceStandardProjectVersionQuery
    field :project_version_models_status_type, resolver: Queries::Lab::FinanceStandardProjectVersionStatusQuery

    field :dataset_overview, resolver: Queries::Lab::DatasetOverviewQuery
    field :dataset_fuzzy_search, resolver: Queries::Lab::DatasetFuzzyQuery

    field :member_overview, resolver: Queries::Lab::MemberOverviewQuery
    field :invitation_overview, resolver: Queries::Lab::InvitationOverviewQuery
    field :my_member_permission, resolver: Queries::Lab::MyMemberPermissionQuery


    ## Lab Metrics

    field :summary_activity, resolver: Queries::ActivitySummaryQuery
    field :summary_community, resolver: Queries::CommunitySummaryQuery
    field :summary_codequality, resolver: Queries::CodequalitySummaryQuery
    field :summary_group_activity, resolver: Queries::GroupActivitySummaryQuery

    field :latest_metrics, resolver: Queries::LatestMetricsQuery
    field :beta_metrics_index, resolver: Queries::BetaMetricsIndexQuery
    field :beta_metric_overview, resolver: Queries::BetaMetricOverviewQuery

    field :collection_hottest, resolver: Queries::CollectionHottestQuery
    field :collection_list, resolver: Queries::CollectionListQuery

    field :current_user, resolver: Queries::CurrentUserQuery
    field :subject_subscription_count, resolver: Queries::SubjectSubscriptionCountQuery

    ## Metrics Details
    field :pulls_detail_list, resolver: Queries::PullsDetailListQuery
    field :issues_detail_list, resolver: Queries::IssuesDetailListQuery
    field :contributors_detail_list, resolver: Queries::ContributorsDetailListQuery

    field :contributors_detail_overview, resolver: Queries::ContributorsDetailOverviewQuery
    field :issues_detail_overview, resolver: Queries::IssuesDetailOverviewQuery
    field :pulls_detail_overview, resolver: Queries::PullsDetailOverviewQuery

    ## Metrics Details Graph
    field :org_contributors_overview, resolver: Queries::OrgContributorsOverviewQuery
    field :org_contributors_distribution, resolver: Queries::OrgContributorsDistributionQuery
    field :org_contribution_distribution, resolver: Queries::OrgContributionDistributionQuery
    field :eco_contributors_overview, resolver: Queries::EcologicalContributorsOverviewQuery

    field :verify_detail_data_range, resolver: Queries::VerifyDetailDataRangeQuery

    ## Metrics Model Graph
    field :metric_models_overview, resolver: Queries::MetricModelsOverviewQuery

    ## Commit
    field :commits_detail_page, resolver: Queries::CommitsDetailPageQuery
    field :commits_contributor_list, resolver: Queries::CommitsContributorListQuery
    field :commits_organization_page, resolver: Queries::CommitsOrganizationPageQuery
    field :commits_repo_page, resolver: Queries::CommitsRepoPageQuery
    field :codes_repo_page, resolver: Queries::CodesRepoPageQuery
    field :codes_detail_page, resolver: Queries::CodesDetailPageQuery
    field :codes_trend, resolver: Queries::CodesTrendQuery
    field :commits_sig_page, resolver: Queries::CommitsSigPageQuery
    field :codes_check_detail_page, resolver: Queries::CodesCheckDetailPageQuery
    field :codes_check_page, resolver: Queries::CodesCheckPageQuery
    field :commit_feedback_page, resolver: Queries::CommitFeedbackPageQuery

    field :organization_page, resolver: Queries::OrganizationPageQuery
    field :subject_access_level_page, resolver: Queries::SubjectAccessLevelPageQuery
    field :subject_sig_page, resolver: Queries::SubjectSigPageQuery
    field :subject_sig_activity_metric, resolver: Queries::SubjectSigActivityMetricQuery
    field :subject_sig_community_metric, resolver: Queries::SubjectSigCommunityMetricQuery
    field :subject_sig_commit_metric, resolver: Queries::SubjectSigCommitMetricQuery

    field :community_detail_overview, resolver: Queries::CommunityDetailOverviewQuery
    field :contribution_detail_overview, resolver: Queries::ContributionDetailOverviewQuery

    field :user_search, resolver: Queries::UserSearchQuery
    field :subject_customization_list, resolver: Queries::SubjectCustomizationListQuery

    ## TPC
    field :tpc_software_sig_list, resolver: Queries::Tpc::TpcSoftwareSigListQuery

    field :tpc_software_selection_report_page, resolver: Queries::Tpc::TpcSoftwareSelectionReportPageQuery
    field :tpc_software_selection_report, resolver: Queries::Tpc::TpcSoftwareSelectionReportQuery
    field :tpc_software_selection_page, resolver: Queries::Tpc::TpcSoftwareSelectionPageQuery
    field :tpc_software_selection_search, resolver: Queries::Tpc::TpcSoftwareSelectionSearchQuery
    field :tpc_software_selection, resolver: Queries::Tpc::TpcSoftwareSelectionQuery


    field :tpc_software_lectotype_report_page, resolver: Queries::Tpc::TpcSoftwareLectotypeReportPageQuery
    field :tpc_software_lectotype_report, resolver: Queries::Tpc::TpcSoftwareLectotypeReportQuery
    field :tpc_software_lectotype_page, resolver: Queries::Tpc::TpcSoftwareLectotypePageQuery
    field :tpc_software_lectotype_search, resolver: Queries::Tpc::TpcSoftwareLectotypeSearchQuery
    field :tpc_software_lectotype, resolver: Queries::Tpc::TpcSoftwareLectotypeQuery

    field :tpc_software_report_metric_clarification_page, resolver: Queries::Tpc::TpcSoftwareReportMetricClarificationPageQuery
    field :tpc_software_report_metric_clarification_permission, resolver: Queries::Tpc::TpcSoftwareReportMetricClarificationPermissionQuery
    field :tpc_software_selection_comment_page, resolver: Queries::Tpc::TpcSoftwareSelectionCommentPageQuery

    field :tpc_software_graduation_report_page, resolver: Queries::Tpc::TpcSoftwareGraduationReportPageQuery
    field :tpc_software_graduation_report, resolver: Queries::Tpc::TpcSoftwareGraduationReportQuery
    field :tpc_software_graduation_page, resolver: Queries::Tpc::TpcSoftwareGraduationPageQuery
    field :tpc_software_graduation, resolver: Queries::Tpc::TpcSoftwareGraduationQuery

    field :tpc_software_my_creation_overview, resolver: Queries::Tpc::TpcSoftwareMyCreationOverviewQuery
    field :tpc_software_my_creation_page, resolver: Queries::Tpc::TpcSoftwareMyCreationPageQuery
    field :tpc_software_my_review_overview, resolver: Queries::Tpc::TpcSoftwareMyReviewOverviewQuery
    field :tpc_software_my_review_page, resolver: Queries::Tpc::TpcSoftwareMyReviewPageQuery


    field :third_txt, resolver: Queries::Third::ThirdTxtQuery
    field :third_tpl, resolver: Queries::Third::ThirdTplQuery


    field :token_list, resolver: Queries::TokenQuery

  end
end
