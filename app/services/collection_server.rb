# frozen_string_literal: true
require 'open3'

class CollectionServer
  include Common

  def execute(directory)
    output, status = Open3.capture2("https_proxy=#{PROXY} git pull", :chdir=>"#{Rails.root + META_REPO}")

    if !status.success?
      job_logger.error "failed to git pull latest, error: #{output}"
      return
    end

    collections =
      "#{Rails.root + META_REPO + directory}.yml"
        .then { File.read _1 }
        .then { YAML.safe_load _1 }
        .reduce({}) do |acc, col|
      items = col['items']
      ident = col['ident']
      if items.is_a?(Array) && ident.is_a?(String)
        items.reduce(acc) { |acc, item| acc.merge({ item => ident }) }
      else
        acc
      end
    end

    Dir.glob("#{Rails.root + META_REPO + directory}/*.yml").each do |file|
      job_logger.info("begin to refresh #{file}")
      begin
        yaml =
          file
            .then { File.read _1 }
            .then { YAML.safe_load _1 }
        collection, items = yaml&.[]('ident'), yaml&.[]('items')
        if collection.is_a?(String) && items.is_a?(Array) && items.present?
          items.each do |label|
            begin
              model = ActivityMetric.build_snapshot(label)
              if model
                BaseCollection.import(
                  OpenStruct.new(
                    model.merge(
                      {
                        id: Digest::SHA1.hexdigest("#{collection}-#{label}"),
                        collection: collection,
                        first_collection: (collections[collection] || 'unknown')
                      }
                    )
                  )
                )
                job_logger.info "successfully generate snaphost of label #{label}."
              else
                job_logger.info "metircs data of label `#{label}` is expired, please re-caculate"
                if label =~ URI::regexp
                  uri = Addressable::URI.parse(label)
                  case AnalyzeServer.new(repo_url: "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}").execute(only_validate: false)
                      in { status: 'pending' }
                      job_logger.info "repo task #{label} dispatch successfully"
                      in { status: :progress }
                      job_logger.warn "last repo task #{label} is still processing"
                      in { status: status, message: message }
                      job_logger.error "repo task #{label} dispatch result: status #{status}, message #{message}"
                  end
                end
              end
            rescue => ex
              job_logger.error "failed to fetch label `#{label}`'s data, error: #{ex.message}"
            end
          end
        end
      rescue => ex
        job_logger.error "failed to refresh collection #{file}, error: #{ex.message}"
      end
      job_logger.info("finished to refresh #{file}")
    end
  end

  def clean_expired(lte: 6.months)
    job_logger.info("begin to clean expired collection data")
    response = BaseCollection.range(:updated_at, lte: Date.today.end_of_day - lte).execute.raw_response
    items = response&.[]('hits')&.[]('hits')
    if items.present?
      models = items.map { |item| OpenStruct.new(item['_source']) }
      models.each do |model|
        job_logger.info("cleaning #{model.to_h}")
        BaseCollection.delete(model)
      end
    else
      job_logger.info("no expired data")
    end
  end

  def job_logger
    Crono.logger.nil? ? Rails.logger : Crono.logger
  end
end
