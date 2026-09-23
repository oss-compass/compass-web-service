# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Queries::CodesRepoPageQuery do
  it 'reports zero PR changes when the repository has no merged pull requests' do
    query = described_class.allocate
    repo_url = 'https://example.com/repo'
    git_indexer = double('git indexer')
    pull_indexer = double('pull indexer')
    git_response = {
      'aggregations' => {
        'group_by_name' => {
          'buckets' => [{ 'key' => "#{repo_url}.git", 'lines_total' => { 'value' => 42 } }]
        }
      }
    }

    allow(ShortenedLabel).to receive(:normalize_label).and_return(repo_url)
    allow(query).to receive(:context).and_return(current_user: Object.new)
    allow(query).to receive(:login_required!)
    allow(query).to receive(:validate_by_label!)
    allow(query).to receive(:extract_date).and_return([Time.utc(2025), Time.utc(2026), nil])
    allow(query).to receive(:select_idx_repos_by_lablel_and_level)
      .and_return([git_indexer, [repo_url]], [pull_indexer, [repo_url]])
    expect(git_indexer).to receive(:fetch_commit_agg_list_by_repo_urls).once.and_return(git_response)
    allow(pull_indexer).to receive(:list_by_repo_urls).and_return('hits' => { 'hits' => [] })
    allow(SubjectSig).to receive(:fetch_subject_sig_list_by_repo_urls).and_return([])
    allow(RepoExtension).to receive(:list_by_repo_urls).and_return('hits' => { 'hits' => [] })

    result = query.resolve(label: repo_url)

    expect(result[:items].first.lines_total).to eq(42)
    expect(result[:items].first.lines_chang).to eq(0)
  end
end
