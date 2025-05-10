# fro_zen_string_literal: true

class GithubReleasesEnrich < GithubBase
  include BaseEnrich
  # include ReleasesEnrich

  def self.index_name
    'github-releases_enriched'
  end

  def self.platform_type
    'github'
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


  def self.terms_by_repo_urls(
    repo_urls, begin_date, end_date,
    target: 'tag.keyword', filter: :grimoire_creation_date, sort: :grimoire_creation_date, direction: :asc,
    filter_opts: [], sort_opts: []
  )
    base =
      self
        .must(terms: { target => repo_urls })
        .range(filter, gte: begin_date, lte: end_date)

    if filter_opts.present?
      filter_opts.each do |filter_opt|
        base = base.where(filter_opt.type => filter_opt.values)
      end
    end

    if sort_opts.present?
      sort_opts.each do |sort_opt|
        base = base.sort(sort_opt.type => sort_opt.direction)
      end
    else
      base = base.sort(sort => direction)
    end

    base
  end

  def self.terms_by_repo_urls_query(
    repo_urls, begin_date, end_date,
    target: 'tag.keyword', filter: :grimoire_creation_date, sort: :grimoire_creation_date, direction: :asc,
    per: 1, page: 1, filter_opts: [], sort_opts: []
  )
    terms_by_repo_urls(
      repo_urls, begin_date, end_date,
      target: target, filter: filter, sort: sort, direction: direction,
      filter_opts: filter_opts, sort_opts: sort_opts
    )
      .page(page)
      .per(per)
      .execute
      .raw_response
  end

  def self.count_by_repo_urls_query(
    repo_urls, begin_date, end_date,
    target: 'tag.keyword', filter: :grimoire_creation_date, filter_opts: []
  )
    base =
      self
        .must(terms: { target => repo_urls })
        .range(filter, gte: begin_date, lte: end_date)
    if filter_opts.present?
      filter_opts.each do |filter_opt|
        base = base.where(filter_opt.type => filter_opt.values)
      end
    end
    base.total_entries
  end


end
