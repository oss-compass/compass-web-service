# frozen_string_literal: true

class MongoIndex < GithubBase

  include BaseEnrich

  def self.index_name
    'mongo'
  end


  def self.query_by_package_id(package)
    resp =  self.must(match_phrase: { 'lib_id.keyword': package })
        .page(1)
        .per(1)
        .execute
        .raw_response

   resp&.dig('hits', 'hits')&.first&.dig('_source') || {}


  end

end
