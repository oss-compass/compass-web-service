class ActivityGroupMetric < BaseMetric
  include BaseModelMetric

  def self.index_name
    "#{MetricsIndexPrefix}_group_activity"
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
        "uuid" => {"type" => "keyword"},
        "level" => {"type" => "keyword"},
        "type" => {"type" => "keyword"},  # 尽管值为 null，仍按字符串类型推断
        "label" => {"type" => "keyword"},
        "model_name" => {"type" => "keyword"},
        "org_name" => {"type" => "keyword"},
        "is_org" => {"type" => "boolean"},
        "contributor_count" => {"type" => "long"},
        "contributor_count_bot" => {"type" => "long"},
        "contributor_count_without_bot" => {"type" => "long"},
        "contributor_org_count" => {"type" => "long"},
        "commit_frequency" => {"type" => "long"},
        "commit_frequency_bot" => {"type" => "long"},
        "commit_frequency_without_bot" => {"type" => "long"},
        "commit_frequency_org" => {"type" => "long"},
        "commit_frequency_org_percentage" => {"type" => "float"},
        "commit_frequency_percentage" => {"type" => "float"},
        "org_count" => {"type" => "long"},
        "contribution_last" => {"type" => "long"},
        "grimoire_creation_date" => {"type" => "date"},
        "metadata__enriched_on" => {"type" => "date"},
        "organizations_activity" => {"type" => "long"}
      }
    }
  end
end
