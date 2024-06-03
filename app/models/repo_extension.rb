# frozen_string_literal: true

class RepoExtension < BaseIndex

  def self.index_name
    'repo_extension'
  end

  def self.mapping
    {
      "properties" => {
          "id" => { "type" => "text", "fields" => { "keyword" => { "type" => "keyword", "ignore_above" => 256 } } },
          "manager" => { "type" => "text", "fields" => { "keyword" => { "type" => "keyword", "ignore_above" => 256 } } },
          "manager_email" => { "type" => "text", "fields" => { "keyword" => { "type" => "keyword", "ignore_above" => 256 } } },
          "platform_type" => { "type" => "text", "fields" => { "keyword" => { "type" => "keyword", "ignore_above" => 256 } } },
          "repo_attribute_type" => { "type" => "text", "fields" => { "keyword" => { "type" => "keyword", "ignore_above" => 256 } } },
          "repo_name" => { "type" => "text", "fields" => { "keyword" => { "type" => "keyword", "ignore_above" => 256 } } },
          "update_at_date" => { "type" => "date" },
          "uuid" => { "type" => "text", "fields" => { "keyword" => { "type" => "keyword", "ignore_above" => 256 } } }
      }
    }
  end

  def self.list_by_repo_urls(repo_urls, filter_opts: [])
    base = self.must(terms: { 'repo_name.keyword': repo_urls})

    if filter_opts.present?
      filter_opts.each do |filter_opt|
        if ["repo_attribute_type", "manager"].include?(filter_opt.type)
          base = base.where(filter_opt.type + '.keyword' => filter_opt.values)
        end
      end
    end
    base.per(repo_urls.length)
        .execute
        .raw_response
  end

end
