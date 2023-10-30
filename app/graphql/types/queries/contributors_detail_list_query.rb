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

      MAX_PER_PAGE = 2000

      def resolve(label: nil, level: 'repo', page: 1, per: 9)
        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(nil, nil)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)

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
               map[row['contributor']] =
                 map[row['contributor']] ?
                   merge_contributor(map[row['contributor']], row) :
                   row
               map
             end
            .map {|_, row| row}


        current_page =
          (contributors_list.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || [])
            .compact
            .map{ |row| OpenStruct.new(row.merge('mileage_type' => nil)) }

        count = contributors_list.length

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: current_page }
      end

      def merge_contributor(source, target)
        base = source.merge(target)
        contribution = source['contribution'].to_i + target['contribution'].to_i
        contribution_without_observe =
          source['contribution_without_observe'].to_i + target['contribution_without_observe'].to_i
        base['contribution'] = contribution
        base['contribution_without_observe'] = contribution_without_observe
        total_contribution_type_list = source['contribution_type_list'] + target['contribution_type_list']
        base['contribution_type_list'] =
          total_contribution_type_list.reduce({}) do |map, row|
          map[row['contribution_type']] =
            map[row['contribution_type']] ?
              map[row['contribution_type']] + row['contribution'] :
              row['contribution']
          map
        end.map {|k, v| {'contribution_type' => k, 'contribution' => v}}
        base
      end
    end
  end
end
