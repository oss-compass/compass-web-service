class GroupActivityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_group_activity"
  end

  def self.mapping
    {"properties"=>
     {"commit_frequency"=>{"type"=>"float"},
      "commit_frequency_bot"=>{"type"=>"float"},
      "commit_frequency_org"=>{"type"=>"long"},
      "commit_frequency_org_percentage"=>{"type"=>"float"},
      "commit_frequency_percentage"=>{"type"=>"float"},
      "commit_frequency_without_bot"=>{"type"=>"float"},
      "contribution_last"=>{"type"=>"long"},
      "contributor_count"=>{"type"=>"long"},
      "contributor_count_bot"=>{"type"=>"long"},
      "contributor_count_without_bot"=>{"type"=>"long"},
      "contributor_org_count"=>{"type"=>"long"},
      "grimoire_creation_date"=>{"type"=>"date"},
      "is_org"=>{"type"=>"boolean"},
      "label"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "level"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "metadata__enriched_on"=>{"type"=>"date"},
      "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "org_count"=>{"type"=>"long"},
      "org_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "organizations_activity"=>{"type"=>"float"},
      "type"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end

  def self.dimension
    'niche_creation'
  end

  def self.ident
    'organizations_activity'
  end

  def self.text_ident
    'organization_activity'
  end

  def self.main_score
    'organizations_activity'
  end

  def self.query_label_one(label, level, type: nil)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:#{level}:#{type}:#{label}",
      expires_in: CacheTTL
    ) do
      base =
        self
          .must(match: { 'label.keyword': label })
          .where(level: level)
          .where(is_org: true)
      base = base.where(type: type) if type
      base
        .page(1)
        .per(1)
        .sort(grimoire_creation_date: :desc)
        .execute
        .raw_response
    end
  end

  def self.find_one(field, value, keyword: true)
    self.must(match: { "#{field}#{keyword ? '.keyword' : ''}" => value })
      .where(is_org: true)
      .page(1)
      .per(1)
      .sort(grimoire_creation_date: :desc)
      .execute
      .raw_response
      .dig('hits', 'hits', 0, '_source')
  end

  def self.aggs_repo_by_date(repo_url, begin_date, end_date, aggs, type: nil)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:#{repo_url}:#{begin_date}:#{end_date}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': repo_url })
        .where(is_org: true)
        .where('type.keyword': type)
        .page(1)
        .per(1)
        .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
        .sort(grimoire_creation_date: :asc)
        .aggregate(aggs)
        .execute
        .raw_response
    end
  end
end
