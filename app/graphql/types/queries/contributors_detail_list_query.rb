# frozen_string_literal: true

module Types
  module Queries
    class ContributorsDetailListQuery < BaseQuery

      type Types::Meta::ContributorDetailPageType, null: false
      description 'Get contributors detail list of a repo or community'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'page size'
      argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
      argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      MAX_PER_PAGE = 2000

      def resolve(
            label: nil, level: 'repo',
            page: 1, per: 9,
            filter_opts: [], sort_opts: [],
            begin_date: nil, end_date: nil
          )
        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)

        contribution_count = 0
        acc_contribution_count = 0
        mileage_step = 0
        mileage_types = ['core', 'regular', 'guest']

        contributors_list =
          indexer
            .must(terms: { 'repo_name.keyword' => repo_urls })
            .page(1)
            .per(MAX_PER_PAGE) # use fake per_page for pagination in raw
            .range(:contribution_without_observe, gte: 1)
            .range(:grimoire_creation_date, gte: begin_date, lte: end_date )
            .sort(grimoire_creation_date: :asc)
            .execute
            .raw_response
            .dig('hits', 'hits')
            .map { |hit| hit['_source'].slice(*Types::Meta::ContributorDetailType.fields.keys.map(&:underscore)) }
            .reduce({}) do |map, row|
               key = row['contributor']
               map[key] = map[key] ? merge_contributor(map[key], row) : row
               contribution_count += row['contribution'].to_i
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

        if filter_opts.present?
          filter_opts.each do |filter_opt|
            contributors_list = contributors_list.select { |row| filter_opt.values.include?(row[filter_opt.type]) }
          end
        end

        if sort_opts.present?
          sort_opts.each do |sort_opt|
            contributors_list =
              contributors_list
                .sort_by { |row| row[sort_opt.type] }
            contributors_list = contributors_list.reverse unless sort_opt.direction == 'asc'
          end
        end

        current_page =
          (contributors_list.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || [])
            .compact
            .map{ |row| OpenStruct.new(row) }

        count = contributors_list.length

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: current_page }
      end

      def merge_contributor(source, target)
        base = source.merge(target)
        base['contribution'] = source['contribution'].to_i + target['contribution'].to_i
        base['contribution_without_observe'] =
          source['contribution_without_observe'].to_i + target['contribution_without_observe'].to_i
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
end
