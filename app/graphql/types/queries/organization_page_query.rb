# frozen_string_literal: true

module Types
  module Queries
    class OrganizationPageQuery < BaseQuery

      type Types::Meta::OrganizationPageType, null: false
      description 'Get organization list'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'
      argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
      argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'

      def resolve(page: 1, per: 9, filter_opts: [], sort_opts: [])
        login_required!(context[:current_user])

        fetch_map = Organization.fetch_organization_agg_map(filter_opts: filter_opts, sort_opts: sort_opts)
        items = fetch_map.map do |key, value|
          skeleton = Hash[Types::Meta::OrganizationType.fields.keys.map(&:underscore).zip([])].symbolize_keys
          skeleton[:org_name] = key
          skeleton[:domain] = value
          skeleton
        end

        current_page =
          (items.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || [])
            .compact
            .map { OpenStruct.new(_1) }

        count = items.length

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: current_page }
      end
    end
  end
end
