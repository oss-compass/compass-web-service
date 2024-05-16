# frozen_string_literal: true

class Organization < BaseIndex

  def self.index_name
    'organizations'
  end

  MAX_PER_PAGE = 10000

  def self.mapping
    {"properties"=>
      {"domain"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "id"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "org_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "update_at_date"=>{"type"=>"date"},
       "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end

  def self.map_by_domain_list(domain_list)
    resp = self
             .must(terms: { 'domain.keyword': domain_list})
             .per(domain_list.length)
             .execute
             .raw_response
    hits = resp&.[]('hits')&.[]('hits') || []
    hits.each_with_object({}) { |hash, map| map[hash['_source']['domain']] = hash['_source'] }
  end

  def self.domain_list_by_org_name_list(org_name_list)
    resp = self
             .must(terms: { 'org_name.keyword': org_name_list})
             .per(org_name_list.length)
             .execute
             .raw_response
    hits = resp&.[]('hits')&.[]('hits') || []
    hits.map{ |item| item['_source']['domain'] }
  end

  def self.domain_list()
    resp = self
             .per(MAX_PER_PAGE)
             .execute
             .raw_response
    hits = resp&.[]('hits')&.[]('hits') || []
    hits.map{ |item| item['_source']['domain'] }
  end

end
