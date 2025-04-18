# frozen_string_literal: true

module BaseModelMetric
  extend ActiveSupport::Concern
  class_methods do

    def base_terms_by_metric_repo_urls(
      repo_urls, begin_date, end_date,
      target: 'label.keyword', filter: :grimoire_creation_date, sort: :grimoire_creation_date, direction: :asc,
      filter_opts: [], sort_opts: []
    )
      base =
        self
          .must(terms: { target => repo_urls })
          .range(filter, gte: begin_date, lte: end_date)

      if filter_opts.present?
        filter_opts.each do |filter_opt|
          base = base.where(filter_opt.type => filter_opt.values)
        end
      end

      if sort_opts.present?
        sort_opts.each do |sort_opt|
          base = base.sort(sort_opt.type => sort_opt.direction)
        end
      else
        base = base.sort(sort => direction)
      end

      puts base.to_json
      puts base.to_query
      base
    end

    def terms_by_metric_repo_urls(
      repo_urls, begin_date, end_date,
      target: 'label.keyword', filter: :grimoire_creation_date, sort: :grimoire_creation_date, direction: :asc,
      per: 1, page: 1, filter_opts: [], sort_opts: []
    )
      base_terms_by_metric_repo_urls(
        repo_urls, begin_date, end_date,
        target: target, filter: filter, sort: sort, direction: direction,
        filter_opts: filter_opts, sort_opts: sort_opts
      )
        .page(page)
        .per(per)
        .execute
        .raw_response
    end

    def count_by_metric_repo_urls(
      repo_urls, begin_date, end_date,
      target: 'label.keyword', filter: :grimoire_creation_date, filter_opts: []
    )
      base =
        self
          .must(terms: { target => repo_urls })
          .range(filter, gte: begin_date, lte: end_date)
      if filter_opts.present?
        filter_opts.each do |filter_opt|
          base = base.where(filter_opt.type => filter_opt.values)
        end
      end
      base.total_entries
    end

    ## Export csv callback

    def on_each(args)
      args[:source]
    end

    def on_finish(args)
      blob = ActiveStorage::Attachment.find_by(blob_id: args[:blob_id], name: 'exports')
      if blob
        Rails.cache.write("export-#{args[:uuid]}", { status: ::Subject::COMPLETE, blob_id: args[:blob_id] })
      else
        Rails.cache.write("export-#{args[:uuid]}", { status: ::Subject::UNKNOWN })
      end
    end
  end
end
