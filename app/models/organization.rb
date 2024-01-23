# frozen_string_literal: true

class Organization < BaseIndex

  def self.index_name
    'organizations'
  end

  def self.mapping
    {"properties"=>
      {"domain"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "id"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "org_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "update_at_date"=>{"type"=>"date"},
       "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end
end
