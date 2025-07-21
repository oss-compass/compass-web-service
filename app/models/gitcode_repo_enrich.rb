# frozen_string_literal: true

class GitcodeRepoEnrich < GitcodeBase
  include BaseEnrich
  # include RepoEnrich

  def self.index_name
    'gitcode-repo_enriched'
  end
  def self.platform_type
    'gitcode'
  end

  def self.mapping
    {
      "dynamic_templates" => [
        {
          "notanalyzed" => {
            "match" => "*",
            "match_mapping_type" => "string",
            "mapping" => {
              "type" => "keyword"
            }
          }
        },
        {
          "formatdate" => {
            "match" => "*",
            "match_mapping_type" => "date",
            "mapping" => {
              "format" => "strict_date_optional_time||epoch_millis",
              "type" => "date"
            }
          }
        }
      ],
      "properties" => {
        "metadata__updated_on" => { "type" => "date" },
        "metadata__timestamp" => { "type" => "date" },
        "offset" => { "type" => "integer" },
        "origin" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "tag" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "uuid" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "forks_count" => { "type" => "integer" },
        "subscribers_count" => { "type" => "integer" },
        "stargazers_count" => { "type" => "integer" },
        "fetched_on" => { "type" => "float" },
        "url" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "status" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "archived" => { "type" => "boolean" },
        "archivedAt" => { "type" => "date" },
        "created_at" => { "type" => "date" },
        "updated_at" => { "type" => "date" },
        "releases" => {
          "type" => "nested",
          "properties" => {
            "id" => { "type" => "integer" },
            "tag_name" => {
              "type" => "text",
              "fields" => {
                "keyword" => {
                  "type" => "keyword",
                  "ignore_above" => 256
                }
              }
            },
            "target_commitish" => {
              "type" => "text",
              "fields" => {
                "keyword" => {
                  "type" => "keyword",
                  "ignore_above" => 256
                }
              }
            },
            "prerelease" => { "type" => "boolean" },
            "name" => {
              "type" => "text",
              "fields" => {
                "keyword" => {
                  "type" => "keyword",
                  "ignore_above" => 256
                }
              }
            },
            "body" => {
              "type" => "text",
              "fields" => {
                "keyword" => {
                  "type" => "keyword",
                  "ignore_above" => 256
                }
              }
            },
            "created_at" => { "type" => "date" },
            "author" => {
              "type" => "nested",
              "properties" => {
                "login" => {
                  "type" => "text",
                  "fields" => {
                    "keyword" => {
                      "type" => "keyword",
                      "ignore_above" => 256
                    }
                  }
                },
                "name" => {
                  "type" => "text",
                  "fields" => {
                    "keyword" => {
                      "type" => "keyword",
                      "ignore_above" => 256
                    }
                  }
                }
              }
            }
          }
        },
        "releases_count" => { "type" => "integer" },
        "topics" => {
          "type" => "nested",
          "properties" => {
            "topic" => {
              "type" => "text",
              "fields" => {
                "keyword" => {
                  "type" => "keyword",
                  "ignore_above" => 256
                }
              }
            }
          }
        },
        "project" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "project_1" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "grimoire_creation_date" => { "type" => "date" },
        "is_gitee_repository" => { "type" => "integer" },
        "repository_labels" => {
          "type" => "nested",
          "properties" => {
            "label" => {
              "type" => "text",
              "fields" => {
                "keyword" => {
                  "type" => "keyword",
                  "ignore_above" => 256
                }
              }
            }
          }
        },
        "metadata__filter_raw" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "metadata__gelk_version" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "metadata__gelk_backend_name" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "metadata__enriched_on" => { "type" => "date" }
      }
    }
  end
end
