# frozen_string_literal: true

class GiteeRepo < GiteeBase

  def self.index_name
    'gitee-repo_raw'
  end

  def self.mapping
    {"dynamic"=>"true",
     "dynamic_templates"=>
     [{"notanalyzed"=>{"match"=>"*", "match_mapping_type"=>"string", "mapping"=>{"type"=>"keyword"}}},
      {"formatdate"=>{"match"=>"*", "match_mapping_type"=>"date", "mapping"=>{"format"=>"strict_date_optional_time||epoch_millis", "type"=>"date"}}}],
     "properties"=>
     {"backend_name"=>{"type"=>"keyword"},
      "backend_version"=>{"type"=>"keyword"},
      "category"=>{"type"=>"keyword"},
      "data"=>{"type"=>"object", "dynamic"=>"false"},
      "metadata__timestamp"=>{"type"=>"date"},
      "metadata__updated_on"=>{"type"=>"date"},
      "origin"=>{"type"=>"keyword"},
      "perceval_version"=>{"type"=>"keyword"},
      "search_fields"=>{"properties"=>{"item_id"=>{"type"=>"keyword"}, "owner"=>{"type"=>"keyword"}, "repo"=>{"type"=>"keyword"}}},
      "tag"=>{"type"=>"keyword"},
      "timestamp"=>{"type"=>"float"},
      "updated_on"=>{"type"=>"float"},
      "uuid"=>{"type"=>"keyword"}}}
  end

  def self.only(origins)
    self
      .where(origin: origins)
      .custom(collapse: { field: :origin })
      .source([
                'origin',
                'backend_name',
                'data.name',
                'data.language',
                'data.full_name',
                'data.forks_count',
                'data.watchers_count',
                'data.stargazers_count',
                'data.open_issues_count',
                'data.created_at',
                'data.updated_at'])
      .execute
      .raw_response
  end

  def self.trends(limit: 24)
    self
      .exists(:origin)
      .custom(collapse: { field: :origin })
      .sort('updated_on': 'desc').page(1).per(limit)
      .source([
                'origin',
                'backend_name',
                'data.name',
                'data.language',
                'data.full_name',
                'data.forks_count',
                'data.watchers_count',
                'data.stargazers_count',
                'data.open_issues_count',
                'data.created_at',
                'data.updated_at'])
      .execute
      .raw_response
  end
end
