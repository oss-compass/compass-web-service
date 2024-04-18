# frozen_string_literal: true
module ContributorEnrich
  extend ActiveSupport::Concern

  MAX_DEPTH = 100
  MAX_PER_PAGE = 8000

  class_methods do
    def fetch_contributors_list(repo_urls, begin_date, end_date, label: nil, level: nil)
      Rails.cache.fetch(contributors_key(repo_urls, begin_date, end_date), expires_in: 15.minutes) do
        contribution_count = 0
        acc_contribution_count = 0
        mileage_step = 0
        mileage_types = ['core', 'regular', 'guest']
        depth = 0
        contributors_map = {}

        query =
          self
            .must(terms: { 'repo_name.keyword' => repo_urls })
            .where(is_bot: false)
            .per(MAX_PER_PAGE)
            .range(:contribution, gt: 0)
            .range(:grimoire_creation_date, gte: begin_date, lte: end_date )
            .sort(grimoire_creation_date: :asc)
            .scroll(timeout: '1m')

        loop do
          query
            .execute
            .raw_response
            .dig('hits', 'hits')
            .map do |hit|
            row = hit['_source'].slice(*Types::Meta::ContributorDetailType.fields.keys.map(&:underscore))
            key = row['contributor']
            contributors_map[key] = contributors_map[key] ? merge_contributor(contributors_map[key], row) : row
            contribution_count += row['contribution'].to_i
          end
          query = query.scroll(id: query.scroll_id, timeout: '1m')
          depth += 1
          break if (query.last_page? || depth > MAX_DEPTH)
        end

        contributors_list =
          contributors_map
            .sort_by { |_, row| -row['contribution_without_observe'].to_i }
            .map do |_, row|
          row['mileage_type'] = (mileage_step < 2 && row['contribution_without_observe'] > 0) ?
                                  mileage_types[mileage_step] : mileage_types[2]
          acc_contribution_count += row['contribution'].to_i
          mileage_step += 1 if mileage_step == 0 && acc_contribution_count >= contribution_count * 0.5
          mileage_step += 1 if mileage_step == 1 && acc_contribution_count >= contribution_count * 0.8
          row
        end
            .sort_by { |row| mileage_types.index(row['mileage_type']) }

        load_organizations(contributors_list, begin_date, end_date, label, level)
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
            elsif filter_opt.type == 'contributor' || filter_opt.type == 'organization'
              contributors.select { |row| filter_opt.values.any? { |value| row[filter_opt.type].starts_with?(value) } }
            elsif filter_opt.type == 'is_bot'
              contributors.select { |row| filter_opt.values.any? { |value| row[filter_opt.type] == (value.to_s.downcase == "true") } }
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

    def load_organizations(contributors, begin_date, end_date, label, level)
      contributor_index = 0
      total_contributors = contributors.length
      contributors_chunks = contributors.in_groups_of(MAX_PER_PAGE)
      last_updated_contributor_indexes = []
      contributors_chunks.each do |chunks|
        chunk_contributors = chunks.compact.map { |o| o['contributor'] }
        [
          ContributorOrg::URL,
          ContributorOrg::RepoAdmin,
          ContributorOrg::SystemAdmin,
          ContributorOrg::UserIndividual
        ].each do |modify_type|
          last_updated_contributor_index = contributor_index
          base =
            ContributorOrg
              .must(terms: { 'contributor.keyword' => chunk_contributors })
              .must(match_phrase: { modify_type: modify_type })
              .where(platform_type: self.platform_type)

          if label.present? && level.present? && !ContributorOrg::GobalScopes.include?(modify_type)
            base = base.must(match: { 'label.keyword': label }).where('level.keyword': level)
          end

          base
            .page(1)
            .per(MAX_PER_PAGE)
            .sort(
              _script: {
                type: 'number',
                script: {
                  inline: "params.sortOrder.indexOf(doc['contributor.keyword'].value)",
                  params: {
                    'sortOrder' => chunk_contributors
                  }
                },
                order: 'asc'
              })
            .execute
            .raw_response
            .dig('hits', 'hits')
            .map do |hit|
            source = hit['_source']
            org_change_date_list = source['org_change_date_list'] || []
            current_contributor = source['contributor']
            current_org = nil
            org_change_date_list.each do |o|
              first_date = (Date.parse(o['first_date']) rescue begin_date)
              last_date = (Date.parse(o['last_date']) rescue Date.today)
              unless begin_date > last_date || end_date < first_date
                current_org = o['org_name']
              end
            end

            if current_org
              loop do
                if contributors[last_updated_contributor_index]['contributor'] == current_contributor
                  contributors[last_updated_contributor_index]['organization'] = current_org
                  contributors[last_updated_contributor_index]['ecological_type'] =
                    contributors[last_updated_contributor_index]['ecological_type'].gsub('individual', 'organization')
                  break
                end
                last_updated_contributor_index += 1
                break unless last_updated_contributor_index < total_contributors
              end
            end
          end
          last_updated_contributor_indexes << last_updated_contributor_index
        end
        contributor_index = last_updated_contributor_indexes.max
        last_updated_contributor_indexes = []
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

    def export_headers
      ['contributor', 'ecological_type', 'organization', 'contribution', 'mileage_type', 'contribution_type_list']
    end

    def on_each(args)
      source = args[:source]
      source['contribution'] = source['contribution_filterd'] if source['contribution_filterd']
      source['contribution_type_list'] = source['contribution_type_list'].map{ |c| c['contribution_type'] }.join('|')
      source
    end
  end
end
