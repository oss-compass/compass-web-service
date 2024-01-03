# frozen_string_literal: true
module ContributorEnrich
  extend ActiveSupport::Concern

  MAX_PER_PAGE = 2000

  class_methods do
    def fetch_contributors_list(repo_urls, begin_date, end_date)
      Rails.cache.fetch(contributors_key(repo_urls, begin_date, end_date), expires_in: 1.day) do
        contribution_count = 0
        acc_contribution_count = 0
        mileage_step = 0
        mileage_types = ['core', 'regular', 'guest']

        self
          .must(terms: { 'repo_name.keyword' => repo_urls })
          .page(1)
          .per(MAX_PER_PAGE)
          .where(is_bot: false)
          .range(:contribution_without_observe, gte: 1)
          .range(:grimoire_creation_date, gte: begin_date, lte: end_date )
          .sort(grimoire_creation_date: :asc)
          .execute
          .raw_response
          .dig('hits', 'hits')
          .map { |hit| hit['_source'].slice(*Types::Meta::ContributorDetailType.fields.keys.map(&:underscore)) }
          .reduce({}) do |map, row|
          key = row['contributor']
          if !['openharmony_ci'].include?(key)
            map[key] = map[key] ? merge_contributor(map[key], row) : row
            contribution_count += row['contribution'].to_i
          end
          map
        end
          .sort_by { |_, row| -row['contribution'].to_i }
          .map do |_, row|
          row['mileage_type'] = mileage_types[mileage_step]
          acc_contribution_count += row['contribution'].to_i
          mileage_step += 1 if mileage_step == 0 && acc_contribution_count >= contribution_count * 0.5
          mileage_step += 1 if mileage_step == 1 && acc_contribution_count >= contribution_count * 0.8
          row
        end
      end
    end

    def contributors_key(repo_urls, begin_date, end_date)
      repos_string = repo_urls.sort.join(',')
      repos_hash = Digest::MD5.hexdigest(repos_string)
      "contributors:#{repos_hash}:#{begin_date}:#{end_date}"
    end

    def append_filtered_contribution(row, filter_opt)
      row.merge(
        {
          'contribution_filterd' =>
          filter_opt.values.map do |value|
            row['contribution_type_list']
              .find { |c| c['contribution_type'] == value }
              &.[]('contribution')
              .to_i
          end
            .reduce(:+)
        }
      )
    end

    def filter_contributors(contributors, filter_opts)
      if filter_opts.present? && filter_opts.respond_to?(:each)
        filter_opts.each do |filter_opt|
          contributors =
            if filter_opt.type == 'contribution_type'
              contributors
                .select { |row| !(filter_opt.values & row['contribution_type_list'].map{|c| c['contribution_type']}).empty? }
                .map { |row| append_filtered_contribution(row, filter_opt) }
            else
              contributors.select { |row| filter_opt.values.include?(row[filter_opt.type]) }
            end
        end
      end
      contributors
    end

    def sort_contributors(contributors, sort_opts)
      if sort_opts.present? && sort_opts.respond_to?(:each)
        sort_opts.each do |sort_opt|
          contributors = contributors.sort_by { |row| row[sort_opt.type] }
          contributors = contributors.reverse unless sort_opt.direction == 'asc'
        end
      end
      contributors
    end

    def repo_admin?(contributor, repo_urls)
      self
        .must(terms: { 'repo_name.keyword' => repo_urls })
        .where('contributor.keyword' => contributor)
        .range(:grimoire_creation_date, gte: Date.today - 1.year, lte: Date.today )
        .should(
          [
            { match: { 'contribution_type_list.contribution_type.keyword' => 'issue_assigned' } },
            { match: { 'contribution_type_list.contribution_type.keyword' => 'pr_merged' } },
          ]
        )
        .page(1)
        .per(1)
        .total_entries > 0
    rescue
      false
    end

    def merge_contributor(source, target)
      base = source.merge(target)
      base['contribution'] = source['contribution'].to_i + target['contribution'].to_i
      base['contribution_without_observe'] =
        source['contribution_without_observe'].to_i + target['contribution_without_observe'].to_i
      ecological_type_sorted = [
        'organization manager',
        'organization participant',
        'individual manager',
        'individual participant'
      ]
      base['ecological_type'] = [source['ecological_type'], target['ecological_type']]
                                  .compact.sort_by { |value| ecological_type_sorted.index(value) }.first
      base['organization'] = target['organization'] ? target['organization'] : source['organization']
      total_contribution_type_list = source['contribution_type_list'] + target['contribution_type_list']
      base['contribution_type_list'] =
        total_contribution_type_list
          .group_by { |row| row['contribution_type'] }
          .map do |type, rows|
        { 'contribution_type' => type, 'contribution' => rows.sum { |row| row['contribution'].to_i } }
      end
      base
    end
  end
end
