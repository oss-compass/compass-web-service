# frozen_string_literal: true

class GithubEventContributor < GithubBase
  include BaseEnrich
  include ContributorEnrich

  def self.index_name
    'github_event_contributor'
  end

  def self.platform_type
    'github'
  end

  def self.mapping
    {
      "properties" => {
        "avatar_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "bio" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "blog" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "collaborators" => { "type" => "long" },
        "commit_domain" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "commit_email" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "commit_patch_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "company" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "created_at" => { "type" => "date" },
        "disk_usage" => { "type" => "long" },
        "domain" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "email" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "events_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "followers" => { "type" => "long" },
        "followers_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "following" => { "type" => "long" },
        "following_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "gists_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "gravatar_id" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "hireable" => { "type" => "boolean" },
        "html_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "id" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "location" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "login" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "name" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "node_id" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "organizations_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "owned_private_repos" => { "type" => "long" },
        "plan" => {
          "properties" => {
            "collaborators" => { "type" => "long" },
            "name" => {
              "type" => "text",
              "fields" => {
                "keyword" => { "type" => "keyword", "ignore_above" => 256 }
              }
            },
            "private_repos" => { "type" => "long" },
            "space" => { "type" => "long" }
          }
        },
        "private_gists" => { "type" => "long" },
        "public_gists" => { "type" => "long" },
        "public_repos" => { "type" => "long" },
        "received_events_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "repos_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "site_admin" => { "type" => "boolean" },
        "starred_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "subscriptions_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "total_private_repos" => { "type" => "long" },
        "twitter_username" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "two_factor_authentication" => { "type" => "boolean" },
        "type" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "tz" => { "type" => "long" },
        "update_at_date" => { "type" => "date" },
        "updated_at" => { "type" => "date" },
        "url" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "user_state" => { "type" => "long" },
        "user_view_type" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        },
        "uuid" => {
          "type" => "text",
          "fields" => {
            "keyword" => { "type" => "keyword", "ignore_above" => 256 }
          }
        }
      }
    }
  end

  def self.query_name(contributor)
    return {} if contributor.blank?

    hit = self.must(match_phrase: { 'login.keyword': contributor })
              .page(1)
              .per(1)
              .execute
              .raw_response&.dig('hits', 'hits', 0)

    return {} unless hit

    hit.dig('_source')
  end

  def self.fuzz_query(contributor)
    return {} if contributor.blank?
    hit = self.must(match_phrase: { 'login.keyword': contributor })
              .page(1)
              .per(100)
              .execute
              .raw_response

  end

end
