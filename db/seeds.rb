# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Initializing Indexes
indices = [
  ActivityMetric, ActivitySummary, BaseCollection,
  CodequalityMetric, CodequalitySummary, CommunityMetric,
  CommunitySummary, CustomV1Metric, GiteeIssueEnrich,
  GiteePullEnrich, GiteeRepoEnrich, GiteeRepo,
  GithubIssueEnrich, GithubPullEnrich, GithubRepoEnrich,
  GithubRepo, GroupActivityMetric, GroupActivitySummary,
  StarterProjectHealthMetric
].each { |indexer| indexer.create_index unless indexer.index_exists? }

metrics_set =
[
  ## git category metrics
  {
    name: 'Created Since', ident: 'created_since', default_weight: 0, default_threshold: 120, category: 'git',
    extra: { extra_fields: ['created_since'] }.to_json
  },
  {
    name: 'Updated Since', ident: 'updated_since', default_weight: 0, default_threshold: 0.25, category: 'git',
    extra: { extra_fields: ['updated_since'] }.to_json
  },
  {
    name: 'Commit Frequency', ident: 'commit_frequency', default_weight: 0, default_threshold: 1000, category: 'git', from: 'CHAOSS',
    extra: { extra_fields: ['commit_frequency', 'commit_frequency_bot', 'commit_frequency_without_bot'] }.to_json
  },
  {
    name: 'Org Count', ident: 'org_count', default_weight: 0, default_threshold: 30, category: 'git',
    extra: { extra_fields: ['org_count'] }.to_json
  },
  {
    name: 'Org Commit Frequency', ident: 'org_commit_frequency', default_weight: 0, default_threshold: 800, category: 'git',
    extra: { extra_fields: ['org_commit_frequency', 'org_commit_frequency_bot', 'org_commit_frequency_without_bot'] }.to_json
  },
  {
    name: 'Org Contribution Last', ident: 'org_contribution_last', default_weight: 0, default_threshold: 160,  category: 'git',
    extra: { extra_fields: ['org_contribution_last'] }.to_json
  },
  {
    name: 'Is Maintained', ident: 'is_maintained', default_weight: 0, default_threshold: 1,  category: 'git', from: 'CHAOSS',
    extra: { extra_fields: ['is_maintained'] }.to_json
  },
  {
    name: 'Commit Pr Linked Ratio', ident: 'commit_pr_linked_ratio', default_weight: 0, default_threshold: 1,  category: 'git', from: 'CHAOSS',
    extra: { extra_fields: ['commit_pr_linked_ratio'] }.to_json
  },
  {
    name: 'Commit Count', ident: 'commit_count', default_weight: 0, default_threshold: 12850,  category: 'git',
    extra: { extra_fields: ['commit_count', 'commit_count_bot', 'commit_count_without_bot'] }.to_json
  },
  {
    name: 'Commit Pr Linked Count', ident: 'commit_pr_linked_count', default_weight: 0, default_threshold: 12850,  category: 'git',
    extra: { extra_fields: ['commit_pr_linked_count'] }.to_json
  },
  {
    name: 'Lines Of Code Frequency', ident: 'lines_of_code_frequency', default_weight: 0, default_threshold: 300000,  category: 'git', from: 'CHAOSS',
    extra: { extra_fields: ['lines_of_code_frequency'] }.to_json
  },
  {
    name: 'Lines Add Of Code Frequency', ident: 'lines_add_of_code_frequency', default_weight: 0, default_threshold: 300000,  category: 'git', from: 'CHAOSS',
    extra: { extra_fields: ['lines_add_of_code_frequency'] }.to_json
  },
  {
    name: 'Lines Remove Of Code Frequency', ident: 'lines_remove_of_code_frequency', default_weight: 0, default_threshold: 300000,  category: 'git', from: 'CHAOSS',
    extra: { extra_fields: ['lines_remove_of_code_frequency'] }.to_json
  },
  ## issue category metrics
  {
    name: 'Issue First Reponse', ident: 'issue_first_reponse', default_weight: 0, default_threshold: 15,  category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['issue_first_reponse_avg', 'issue_first_reponse_mid'] }.to_json
  },
  {
    name: 'Bug Issue Open Time', ident: 'bug_issue_open_time', default_weight: 0, default_threshold: 60,  category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['bug_issue_open_time_avg', 'bug_issue_open_time_mid'] }.to_json
  },
  {
    name: 'Comment Frequency', ident: 'comment_frequency', default_weight: 0, default_threshold: 5,  category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['comment_frequency'] }.to_json
  },
  {
    name: 'Closed Issues Count', ident: 'closed_issues_count', default_weight: 0, default_threshold: 2500,  category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['closed_issues_count'] }.to_json
  },
  {
    name: 'Updated Issues Count', ident: 'updated_issues_count', default_weight: 0, default_threshold: 2500,  category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['updated_issues_count'] }.to_json
  },
  ## pr category metrics
  {
    name: 'Pr Open Time', ident: 'pr_open_time', default_weight: 0, default_threshold: 30,  category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['pr_open_time_avg', 'pr_open_time_mid'] }.to_json
  },
  {
    name: 'Code Review Count', ident: 'code_review_count', default_weight: 0, default_threshold: 8,  category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['code_review_count'] }.to_json
  },
  {
    name: 'Close Pr Count', ident: 'close_pr_count', default_weight: 0, default_threshold: 4500,  category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['close_pr_count'] }.to_json
  },
  {
    name: 'Pr Time To First Response', ident: 'pr_time_to_first_response', default_weight: 0, default_threshold: 15,  category: 'pr',
    extra: { extra_fields: ['pr_time_to_first_response_avg', 'pr_time_to_first_response_mid'] }.to_json
  },
  {
    name: 'Change Request Closure Ratio', ident: 'change_request_closure_ratio', default_weight: 0, default_threshold: 1,  category: 'pr',
    extra: { extra_fields: ['change_request_closure_ratio'] }.to_json
  },
  {
    name: 'Change Request Closure Ratio Recently Period', ident: 'change_request_closure_ratio_recently_period', default_weight: 0, default_threshold: 1, category: 'pr',
    extra: { extra_fields: ['change_request_closure_ratio_recently_period'] }.to_json
  },
  {
    name: 'Code Review Ratio', ident: 'code_review_ratio', default_weight: 0, default_threshold: 1, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['code_review_ratio'] }.to_json
  },
  {
    name: 'Pr Count', ident: 'pr_count', default_weight: 0, default_threshold: 4500, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['pr_count'] }.to_json
  },
  {
    name: 'Pr Count With Review', ident: 'pr_count_with_review', default_weight: 4500, default_threshold: 1, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['pr_count_with_review'] }.to_json
  },
  {
    name: 'Code Merge Ratio', ident: 'code_merge_ratio', default_weight: 0, default_threshold: 1, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['code_merge_ratio'] }.to_json
  },
  {
    name: 'Pr Issue Linked Ratio', ident: 'pr_issue_linked_ratio', default_weight: 0, default_threshold: 1, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['pr_issue_linked_ratio'] }.to_json
  },
  {
    name: 'Total Create Close Pr Count', ident: 'total_create_close_pr_count', default_weight: 0, default_threshold: 20000, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['total_create_close_pr_count'] }.to_json
  },
  {
    name: 'Total Pr Count', ident: 'total_pr_count', default_weight: 0, default_threshold: 20000, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['total_pr_count'] }.to_json
  },
  {
    name: 'Create Close Pr Count', ident: 'create_close_pr_count', default_weight: 0, default_threshold: 4500, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['create_close_pr_count'] }.to_json
  },
  {
    name: 'Code Merge Count With Non Author', ident: 'code_merge_count_with_non_author', default_weight: 0, default_threshold: 4500, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['code_merge_count_with_non_author'] }.to_json
  },
  {
    name: 'Code Merge Count', ident: 'code_merge_count', default_weight: 0, default_threshold: 4500, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['code_merge_count'] }.to_json
  },
  {
    name: 'Pr Issue Linked Count', ident: 'pr_issue_linked_count', default_weight: 0, default_threshold: 4500, category: 'pr', from: 'CHAOSS',
    extra: { extra_fields: ['pr_issue_linked_count'] }.to_json
  },
  ## repo category metrics
  {
    name: 'Recent Releases Count', ident: 'recent_releases_count', default_weight: 0, default_threshold: 12, category: 'repo',
    extra: { extra_fields: ['recent_releases_count'] }.to_json
  },
  ## contributor category metrics
  {
    name: 'Contributor Count', ident: 'contributor_count', default_weight: 0, default_threshold: 2000, category: 'contributor',
    extra: { extra_fields: ['contributor_count', 'contributor_count_bot', 'contributor_count_without_bot'] }.to_json
  },
  {
    name: 'Code Contributor Count', ident: 'code_contributor_count', default_weight: 0, default_threshold: 1000, category: 'contributor', from: 'CHAOSS',
    extra: { extra_fields: ['code_contributor_count', 'code_contributor_count_bot', 'code_contributor_count_without_bot'] }.to_json
  },
  {
    name: 'Commit Contributor Count', ident: 'commit_contributor_count', default_weight: 0, default_threshold: 1000, category: 'contributor', from: 'CHAOSS',
    extra: { extra_fields: ['commit_contributor_count', 'commit_contributor_count_bot', 'commit_contributor_count_without_bot'] }.to_json
  },
  {
    name: 'Pr Authors Contributor Count', ident: 'pr_authors_contributor_count', default_weight: 0, default_threshold: 1000, category: 'contributor', from: 'CHAOSS',
    extra: { extra_fields: ['pr_authors_contributor_count', 'pr_authors_contributor_count_bot', 'pr_authors_contributor_count_without_bot'] }.to_json
  },
  {
    name: 'Pr Review Contributor Count', ident: 'pr_review_contributor_count', default_weight: 0, default_threshold: 1000, category: 'contributor', from: 'CHAOSS',
    extra: { extra_fields: ['pr_review_contributor_count', 'pr_review_contributor_count_bot', 'pr_review_contributor_count_without_bot'] }.to_json
  },
  {
    name: 'Issue Authors Contributor Count', ident: 'issue_authors_contributor_count', default_weight: 0, default_threshold: 1000, category: 'contributor', from: 'CHAOSS',
    extra: { extra_fields: ['issue_authors_contributor_count', 'issue_authors_contributor_count_bot', 'issue_authors_contributor_count_without_bot'] }.to_json
  },
  {
    name: 'Issue Comments Contributor Count', ident: 'issue_comments_contributor_count', default_weight: 0, default_threshold: 1000, category: 'contributor', from: 'CHAOSS',
    extra: { extra_fields: ['issue_comments_contributor_count', 'issue_comments_contributor_count_bot', 'issue_comments_contributor_count_without_bot'] }.to_json
  },
  {
    name: 'Org Contributor Count', ident: 'org_contributor_count', default_weight: 0, default_threshold: 300, category: 'contributor',
    extra: { extra_fields: ['org_contributor_count', 'org_contributor_count_bot', 'org_contributor_count_without_bot'] }.to_json
  },
  {
    name: 'Bus Factor', ident: 'bus_factor', default_weight: 0, default_threshold: 5, category: 'contributor',
    extra: { extra_fields: ['bus_factor'] }.to_json
  },
]

metrics_set_ids =
  metrics_set.map do |metric_set|
  metric = LabMetric.find_or_initialize_by(ident: metric_set[:ident])
  metric.update!(metric_set)
  metric.id
end

LabMetric.where.not(id: metrics_set_ids).destroy_all

algorithm = LabAlgorithm.find_or_initialize_by(ident: 'default')
algorithm.extra = 'criticality_score'
algorithm.save!

beta_metric = BetaMetric.find_or_initialize_by(metric: 'StarterProjectHealth')
beta_metric.dimensionality = 'Lab'
beta_metric.desc = 'This metrics model is designed to help people get started with four key project health metrics that they can expand on and customize to meet their unique needs later.'
beta_metric.status = nil
beta_metric.workflow = 'LAB_V1'
beta_metric.project = 'insight'
beta_metric.op_index = 'starter_project_health'
beta_metric.op_metric = 'StarterProjectHealthMetric'
beta_metric.extra = 'https://chaoss.community/kb/metrics-model-starter-project-health/'
beta_metric.save!
