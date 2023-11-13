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

        contributors_list = indexer.fetch_contributors_list(repo_urls, begin_date, end_date)

        if filter_opts.present?
          filter_opts.each do |filter_opt|
            contributors_list =
              if filter_opt.type == 'contribution_type'
                contributors_list.select { |row| !(filter_opt.values & row['contribution_type_list'].map{|c| c['contribution_type']}).empty? }
              else
                contributors_list.select { |row| filter_opt.values.include?(row[filter_opt.type]) }
              end
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
    end
  end
end
