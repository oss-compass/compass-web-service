# frozen_string_literal: true

class StarterProjectHealthMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_starter_project_health"
  end

  def self.mapping
    {"properties"=>
     {"bus_factor"=>{"type"=>"long"},
      "change_request_closed_count_all_period"=>{"type"=>"long"},
      "change_request_closed_count_recently"=>{"type"=>"long"},
      "change_request_closure_ratio_all_period"=>{"type"=>"float"},
      "change_request_closure_ratio_recently"=>{"type"=>"float"},
      "change_request_created_count_all_period"=>{"type"=>"long"},
      "change_request_created_count_recently"=>{"type"=>"long"},
      "grimoire_creation_date"=>{"type"=>"date"},
      "label"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "level"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "metadata__enriched_on"=>{"type"=>"date"},
      "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "pr_time_to_close_avg"=>{"type"=>"float"},
      "pr_time_to_close_mid"=>{"type"=>"float"},
      "pr_time_to_first_response_avg"=>{"type"=>"float"},
      "pr_time_to_first_response_mid"=>{"type"=>"float"},
      "release_frequency"=>{"type"=>"long"},
      "starter_project_health"=>{"type"=>"float"},
      "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end
end
