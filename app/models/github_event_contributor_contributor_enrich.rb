# frozen_string_literal: true

class GithubEventContributorContributorEnrich < GithubBase

  include BaseEnrich
  include ContributorContributorEnrich

  def self.index_name
    'github_event_contributor_contributor_enrich'
  end

  def self.platform_type
    'github'
  end

  def self.mapping
    {
      'created_at' => {
        'type' => 'date'
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
      'from_city' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'from_city_raw' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'from_contributor' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'from_country' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'from_created_at' => {
        'type' => 'date'
      },
      'from_email_domain' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'from_org' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'from_province' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'from_tz' => {
        'type' => 'long'
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
      'issue_comment_created_indirect_contribution' => {
        'type' => 'long'
      },
      'issues_opened_contribution' => {
        'type' => 'long'
      },
      'pull_request_opened_contribution' => {
        'type' => 'long'
      },
      'pull_request_review_comment_created_contribution' => {
        'type' => 'long'
      },
      'pull_request_review_comment_created_indirect_contribution' => {
        'type' => 'long'
      },
      'to_city' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'to_city_raw' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'to_contributor' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'to_country' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'to_created_at' => {
        'type' => 'date'
      },
      'to_email_domain' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'to_org' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'to_province' => {
        'type' => 'text',
        'fields' => {
          'keyword' => {
            'type' => 'keyword',
            'ignore_above' => 256
          }
        }
      },
      'to_tz' => {
        'type' => 'long'
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
      }
    }
  end

end
