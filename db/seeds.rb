# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

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
    extra: { extra_fields: ['org_commit_frequency', 'org_commit_frequency_bot', 'org_commit_frequency_without_bot', 'org_commit_frequency_list'] }.to_json
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
    extra: { extra_fields: ['commit_pr_linked_ratio', 'commit_pr', 'commit_pr_linked'] }.to_json
  },
  {
    name: 'Lines Of Code Frequency', ident: 'lines_of_code_frequency', default_weight: 0, default_threshold: 300000,  category: 'git', from: 'CHAOSS',
    extra: { extra_fields: ['lines_of_code_frequency', 'lines_add_of_code_frequency', 'lines_remove_of_code_frequency'] }.to_json
  },
  ## issue category metrics
  {
    name: 'Pr Open Time', ident: 'pr_open_time', default_weight: 0, default_threshold: 30,  category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['pr_open_time_avg', 'pr_open_time_mid'] }.to_json
  },
  {
    name: 'Code Review Count', ident: 'code_review_count', default_weight: 0, default_threshold: 8,  category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['code_review_count'] }.to_json
  },
  {
    name: 'Close Pr Count', ident: 'close_pr_count', default_weight: 0, default_threshold: 4500,  category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['close_pr_count'] }.to_json
  },
  {
    name: 'Pr Time To First Response', ident: 'pr_time_to_first_response', default_weight: 0, default_threshold: 15,  category: 'issue',
    extra: { extra_fields: ['pr_time_to_first_response_avg', 'pr_time_to_first_response_mid'] }.to_json
  },
  {
    name: 'Change Request Closure Ratio', ident: 'change_request_closure_ratio', default_weight: 0, default_threshold: 1,  category: 'issue',
    extra: { extra_fields: ['change_request_closure_ratio', 'change_request_closed_count', 'change_request_created_count'] }.to_json
  },
  {
    name: 'Change Request Closure Ratio Recently Period', ident: 'change_request_closure_ratio_recently_period', default_weight: 0, default_threshold: 1, category: 'issue',
    extra: { extra_fields: ['change_request_closure_ratio_recently_period', 'change_request_closed_count_recently_period', 'change_request_created_count_recently_period'] }.to_json
  },
  {
    name: 'Code Review Ratio', ident: 'code_review_ratio', default_weight: 0, default_threshold: 1, category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['code_review_ratio', 'total_pr', 'code_review'] }.to_json
  },
  {
    name: 'Code Merge Ratio', ident: 'code_merge_ratio', default_weight: 0, default_threshold: 1, category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['code_merge_ratio', 'code_merge', 'code_merge_total'] }.to_json
  },
  {
    name: 'Pr Issue Linked Ratio', ident: 'pr_issue_linked_ratio', default_weight: 0, default_threshold: 1, category: 'issue', from: 'CHAOSS',
    extra: { extra_fields: ['pr_issue_linked_ratio', 'total_pr', 'pr_issue_linked'] }.to_json
  },
  ## repo category metrics
  {
    name: 'Recent Releases Count', ident: 'recent_releases_count', default_weight: 0, default_threshold: 12, category: 'repo',
    extra: { extra_fields: ['recent_releases_count'] }.to_json
  },
  ## contributor category metrics
  {
    name: 'Contributor Count', ident: 'contributor_count', default_weight: 0, default_threshold: 2000, category: 'contributor',
    extra: { extra_fields: ['contributor_count', 'contributor_count_bot', 'contributor_count_without_bot', 'active_C2_contributor_count', 'active_C1_pr_create_contributor', 'active_C1_pr_comments_contributor', 'active_C1_issue_create_contributor', 'active_C1_issue_comments_contributor'] }.to_json
  },
  {
    name: 'Code Contributor Count', ident: 'code_contributor_count', default_weight: 0, default_threshold: 1000, category: 'contributor', from: 'CHAOSS',
    extra: { extra_fields: ['code_contributor_count', 'code_contributor_count_bot', 'code_contributor_count_without_bot', 'active_C2_contributor_count', 'active_C1_pr_create_contributor', 'active_C1_pr_comments_contributor'] }.to_json
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
