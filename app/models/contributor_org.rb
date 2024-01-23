# frozen_string_literal: true

class ContributorOrg < BaseIndex
  URL = 'URL'
  RepoAdmin = 'Repo Admin'
  SystemAdmin = 'System Admin'
  UserIndividual = 'User Individual'
  GobalScopes = [UserIndividual]

  def self.index_name
    'contributor_org'
  end

  def self.mapping
    {"properties"=>
      {"contributor"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "id"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "is_bot"=>{"type"=>"boolean"},
       "modify_by"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "modify_type"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "org_change_date_list"=>
        {"properties"=>
          {"first_date"=>{"type"=>"date"}, "last_date"=>{"type"=>"date"}, "org_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}},
       "plateform_type"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
       "update_at_date"=>{"type"=>"date"},
       "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end
end
