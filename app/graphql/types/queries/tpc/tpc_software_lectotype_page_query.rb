# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareLectotypePageQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareLectotypePageType, null: true
        description 'Get tpc software lectotype list'
        argument :label, String, required: false, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or project level(repo/community)'
        argument :lectotype_type, Integer, required: true, description: 'incubation: 0, sandbox: 1, graduation: 2'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'
        argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
        argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'

        def resolve(label: nil, level: nil, lectotype_type: 0, page: 1, per: 9, filter_opts: nil, sort_opts: nil)
          subject = Subject.find_by(label: label, level: level)

          items = []
          if subject.present?
            items = TpcSoftwareLectotype.joins(:user)
                                        .where("tpc_software_lectotypes.lectotype_type = ?", lectotype_type)
                                        .where("tpc_software_lectotypes.subject_id = ?", subject.id)
            if filter_opts.present?
              filter_opts.each do |filter_opt|
                if filter_opt.type == "user"
                  conditions = filter_opt.values.map { |value| "users.name LIKE ?" }.join(" OR ")
                  like_values = filter_opt.values.map { |value| "%#{value}%" }
                else
                  conditions = filter_opt.values.map { |value| "tpc_software_lectotypes.#{filter_opt.type} LIKE ?" }.join(" OR ")
                  like_values = filter_opt.values.map { |value| "%#{value}%" }
                end
                items = items.where(conditions, *like_values)
              end
            end
            if sort_opts.present?
              sort_opts.each do |sort_opt|
                items = items.order("tpc_software_lectotypes.#{sort_opt.type} #{sort_opt.direction}")
              end
            else
              items = items.order("tpc_software_lectotypes.created_at desc")
            end
          end

          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
    end
  end
end
