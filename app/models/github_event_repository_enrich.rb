# frozen_string_literal: true

class GithubEventRepositoryEnrich < GithubBase

  include BaseEnrich
  include ContributorRepoEnrich

  def self.index_name
    'github_event_repository_enrich'
  end

  def self.platform_type
    'github'
  end

  def self.mapping
    {
      'created_at' => { 'type' => 'date' },
      'fork_contribution' => { 'type' => 'long' },
      'freq' => {
        'type' => 'text',
        'fields' => {
          'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
        }
      },
      'id' => {
        'type' => 'text',
        'fields' => {
          'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
        }
      },
      'is_community' => { 'type' => 'boolean' },
      'issues_closed_contribution' => { 'type' => 'long' },
      'issues_opened_contribution' => { 'type' => 'long' },
      'issues_reopened_contribution' => { 'type' => 'long' },
      'license' => {
        'type' => 'text',
        'fields' => {
          'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
        }
      },
      'main_language_list' => {
        'type' => 'text',
        'fields' => {
          'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
        }
      },
      'owner' => {
        'type' => 'text',
        'fields' => {
          'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
        }
      },
      'pull_request_closed_contribution' => { 'type' => 'long' },
      'pull_request_merged_contribution' => { 'type' => 'long' },
      'pull_request_opened_contribution' => { 'type' => 'long' },
      'pull_request_reopened_contribution' => { 'type' => 'long' },
      'pull_request_review_approved_contribution' => { 'type' => 'long' },
      'pull_request_review_changes_requested_contribution' => { 'type' => 'long' },
      'pull_request_review_commented_contribution' => { 'type' => 'long' },
      'push_contribution' => { 'type' => 'long' },
      'push_contributor_count' => { 'type' => 'long' },
      'push_contributor_tz_list' => {
        'properties' => {
          'user_login' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          },
          'tz' => { 'type' => 'long' },
          'push_contribution' => { 'type' => 'long' },
          'country' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          },
          'province' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          },
          'city' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          },
          'city_raw' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          }
        }
      },
      'push_core_contributor_tz_list' => {
        'properties' => {
          'user_login' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          },
          'tz' => { 'type' => 'long' },
          'push_contribution' => { 'type' => 'long' },
          'country' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          },
          'province' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          },
          'city' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          },
          'city_raw' => {
            'type' => 'text',
            'fields' => {
              'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
            }
          }
        }
      },
      'repo' => {
        'type' => 'text',
        'fields' => {
          'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
        }
      },
      'repo_created_at' => { 'type' => 'date' },
      'sssue_comment_created_contribution' => { 'type' => 'long' },
      'topic_list' => {
        'type' => 'text',
        'fields' => {
          'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
        }
      },
      'total_contribution' => { 'type' => 'long' },
      'update_at_date' => { 'type' => 'date' },
      'uuid' => {
        'type' => 'text',
        'fields' => {
          'keyword' => { 'type' => 'keyword', 'ignore_above' => 256 }
        }
      },
      'watch_started_contribution' => { 'type' => 'long' }
    }
  end

  def self.query_core_project(contributor, begin_date, end_date, page: 1, per: 1)
    resp = self.must(match_phrase: { 'push_core_contributor_tz_list.user_login': contributor })
               .range('created_at', gte: begin_date, lte: end_date)
               .page(page)
               .per(per)
               .execute
               .raw_response

    sources = resp&.dig('hits', 'hits')&.map { |hit| hit['_source'] } || []
    sources.flat_map { |item| item["repo"] || [] }.uniq

  end



end
