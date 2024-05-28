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
             .per(MAX_PER_PAGE)
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

  def self.fetch_organization_agg_map(filter_opts: [], sort_opts: [])
    base = self.aggregate(
      group_by_name: {
        terms: { field: 'org_name.keyword', size: MAX_PER_PAGE },
        aggs: {
          group_by_name: {
            terms: { field: 'domain.keyword', size: MAX_PER_PAGE },
          }
        }
      }
    )

    if filter_opts.present?
      filter_opts.each do |filter_opt|
        base = base.must(wildcard: { filter_opt.type + '.keyword' => { value: "*#{filter_opt.values.first}*" } })
      end
    end

    resp = base.per(0)
               .execute
               .raw_response
    (resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []).each_with_object({}) do |data, hash|
      domain_list = (data&.[]('group_by_name')&.[]('buckets') || []).map do |domain|
        domain['key']
      end
      hash[data['key']] = domain_list
    end
  end

  def self.delete_by_org_name(org_name)
    self.must(term: { 'org_name.keyword' => org_name })
        .delete
  end




end
