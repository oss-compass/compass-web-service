# fro_zen_string_literal: true

class GiteeReleasesEnrich < GiteeBase
  include BaseEnrich
  # include ReleasesEnrich

  def self.index_name
    'gitee-releases_enriched'
  end

  def self.platform_type
    'gitee'
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
        "user_id" => { "type" => "long" },
        "user_login" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "user_name" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "auhtor_name" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "user_html_url" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "user_email" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "user_company" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "user_remark" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "user_type" => {
          "type" => "text",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
              "ignore_above" => 256
            }
          }
        },
        "star_at" => { "type" => "date" },
        "created_at" => { "type" => "date" },
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
        "is_gitee_stargazer" => { "type" => "integer" },
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