# frozen_string_literal: true

class GithubEventContributorRepoEnrich < GithubBase

  include BaseEnrich
  include ContributorRepoEnrich

  def self.index_name
    'github_event_contributor_repo_enrich'
  end

  def self.platform_type
    'github'
  end


  def self.mapping
    {
      'contributor' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'contributor_city' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'contributor_city_raw' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'contributor_country' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'contributor_created_at' => {
        'type' => 'date'
      },
      'contributor_email_domain' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'contributor_org' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'contributor_province' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'contributor_tz' => {
        'type' => 'long'
      },
      'created_at' => {
        'type' => 'date'
      },
      'fork_contribution' => {
        'type' => 'long'
      },
      'freq' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'id' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'issue_comment_created_contribution' => {
        'type' => 'long'
      },
      'issues_closed_contribution' => {
        'type' => 'long'
      },
      'issues_opened_contribution' => {
        'type' => 'long'
      },
      'issues_reopened_contribution' => {
        'type' => 'long'
      },
      'pull_request_additions' => {
        'type' => 'long'
      },
      'pull_request_closed_contribution' => {
        'type' => 'long'
      },
      'pull_request_deletions' => {
        'type' => 'long'
      },
      'pull_request_merged_contribution' => {
        'type' => 'long'
      },
      'pull_request_opened_contribution' => {
        'type' => 'long'
      },
      'pull_request_reopened_contribution' => {
        'type' => 'long'
      },
      'pull_request_review_approved_contribution' => {
        'type' => 'long'
      },
      'pull_request_review_changes_requested_contribution' => {
        'type' => 'long'
      },
      'pull_request_review_commented_contribution' => {
        'type' => 'long'
      },
      'push_contribution' => {
        'type' => 'long'
      },
      'repo' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'repo_created_at' => {
        'type' => 'date'
      },
      'repo_license' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'repo_main_language' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'repo_topic_list' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'total_contribution' => {
        'type' => 'long'
      },
      'update_at_date' => {
        'type' => 'date'
      },
      'uuid' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'watch_started_contribution' => {
        'type' => 'long'
      }
    }
  end




end
