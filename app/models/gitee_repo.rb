# frozen_string_literal: true

class GiteeRepo < GiteeBase

  def self.index_name
    'gitee-repo_raw'
  end

  def self.trends(limit: 24)
    self
      .exists(:origin)
      .custom(collapse: { field: :origin })
      .sort('updated_on': 'desc').page(1).per(limit)
      .source([
                'origin',
                'backend_name',
                'data.name',
                'data.language',
                'data.full_name',
                'data.forks_count',
                'data.watchers_count',
                'data.stargazers_count',
                'data.open_issues_count',
                'data.created_at',
                'data.updated_at'])
      .execute
      .raw_response
  end
end
