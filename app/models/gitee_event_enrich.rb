# frozen_string_literal: true

class GiteeEventEnrich < GiteeBase

  include BaseEnrich

  def self.index_name
    'gitee-event_enriched'
  end

  def self.mapping
    {
      "dynamic_templates" => [
        {
          "notanalyzed" => {
            "match" => "*",
            "match_mapping_type" => "string",
            "mapping" => {"type" => "keyword"}
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
        # Metadata fields
        "metadata__updated_on" => {"type" => "date"},
        "metadata__timestamp" => {"type" => "date"},
        "metadata__enriched_on" => {"type" => "date"},
        "metadata__gelk_version" => {"type" => "keyword"},
        "metadata__gelk_backend_name" => {"type" => "keyword"},
        "metadata__filter_raw" => {"type" => "keyword"},

        # Core identifiers
        "uuid" => {"type" => "keyword"},
        "offset" => {"type" => "keyword"},
        "origin" => {"type" => "keyword"},
        "tag" => {"type" => "keyword"},
        "id" => {"type" => "long"},
        "icon" => {"type" => "keyword"},

        # Event information
        "event_type" => {"type" => "keyword"},
        "action_type" => {"type" => "keyword"},
        "content" => {"type" => "keyword"},
        "created_at" => {"type" => "date"},
        "pull_request" => {"type" => "boolean"},
        "item_type" => {"type" => "keyword"},
        "is_gitee_event" => {"type" => "long"},

        # Issue details
        "issue_id" => {"type" => "long"},
        "issue_id_in_repo" => {"type" => "keyword"},
        "issue_title" => {"type" => "keyword"},
        "issue_title_analyzed" => {"type" => "text"},
        "issue_state" => {"type" => "keyword"},
        "issue_created_at" => {"type" => "date"},
        "issue_updated_at" => {"type" => "date"},
        "issue_closed_at" => {"type" => "date"},
        "issue_finished_at" => {"type" => "date"},
        "issue_url" => {"type" => "keyword"},
        "issue_labels" => {"type" => "keyword"},
        "issue_url_id" => {"type" => "keyword"},

        # Repository information
        "repository" => {"type" => "keyword"},
        "gitee_repo" => {"type" => "keyword"},
        "repository_labels" => {"type" => "keyword"},

        # Project tracking
        "project" => {"type" => "keyword"},
        "project_1" => {"type" => "keyword"},
        "grimoire_creation_date" => {"type" => "date"},

        # Actor/User information
        "actor_username" => {"type" => "keyword"},
        "user_login" => {"type" => "keyword"},
        "actor_id" => {"type" => "keyword"},
        "actor_uuid" => {"type" => "keyword"},
        "actor_name" => {"type" => "keyword"},
        "actor_user_name" => {"type" => "keyword"},
        "actor_domain" => {"type" => "keyword"},
        "actor_gender" => {"type" => "keyword"},
        "actor_gender_acc" => {"type" => "long"},
        "actor_org_name" => {"type" => "keyword"},
        "actor_bot" => {"type" => "boolean"},
        "actor_multi_org_names" => {"type" => "keyword"},

        # Reporter information
        "reporter_id" => {"type" => "keyword"},
        "reporter_uuid" => {"type" => "keyword"},
        "reporter_name" => {"type" => "keyword"},
        "reporter_user_name" => {"type" => "keyword"},
        "reporter_domain" => {"type" => "keyword"},
        "reporter_gender" => {"type" => "keyword"},
        "reporter_gender_acc" => {"type" => "long"},
        "reporter_org_name" => {"type" => "keyword"},
        "reporter_bot" => {"type" => "boolean"},
        "reporter_multi_org_names" => {"type" => "keyword"}
      }
    }
  end

end
