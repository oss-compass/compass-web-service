# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareMyReviewPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareMyCreationAndReviewPageType, null: true
        description 'Get tpc software my review page'
        argument :label, String, required: true, description: 'repo or project label'
        argument :level, String, required: true, description: 'repo or project level(repo/community)'
        argument :application_type, Integer, required: true, description: '0: incubation 1: graduation'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'
        argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
        argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'

        def resolve(label: nil, level: nil, application_type: 0, page: 1, per: 9, filter_opts: nil, sort_opts: nil)
          subject = Subject.find_by(label: label, level: level)
          current_user = context[:current_user]
          validate_tpc!(current_user)

          items = []
          if subject.present?
            case application_type
            when 0
              tpc_software = TpcSoftwareSelection
            when 1
              tpc_software = TpcSoftwareGraduation
            else
              tpc_software = TpcSoftwareSelection
            end

            if TpcSoftwareMember.check_sig_lead_permission?(current_user) ||
              TpcSoftwareMember.check_legal_permission?(current_user) ||
              TpcSoftwareMember.check_compliance_permission?(current_user)
              items = tpc_software.joins(:user, :tpc_software_report)
                                  .where(subject_id: subject.id)
                                  .where.not(issue_url: nil)
                                  .where.not(state: nil)
                                  .where.not(tpc_software_report: { tpc_software_sig_id: nil })
            else
              committer_list = TpcSoftwareMember.get_committer_list(current_user, subject.id)
              if committer_list.present?
                sig_id_list = committer_list.map { |committer| committer.tpc_software_sig_id }
                items = tpc_software.joins(:user, :tpc_software_report)
                                    .where(subject_id: subject.id)
                                    .where.not(state: nil)
                                    .where.not(issue_url: nil)
                                    .where(tpc_software_report: { tpc_software_sig_id: sig_id_list })
              end
            end

            if items.is_a?(ActiveRecord::Relation)
              if filter_opts.present?
                filter_opts.each do |filter_opt|
                  if filter_opt.type == "user"
                    conditions = filter_opt.values.map { |value| "users.name LIKE ?" }.join(" OR ")
                    like_values = filter_opt.values.map { |value| "%#{value}%" }
                  elsif filter_opt.type == "name"
                    conditions = filter_opt.values.map { |value| "tpc_software_report.name LIKE ?" }.join(" OR ")
                    like_values = filter_opt.values.map { |value| "%#{value}%" }
                  else
                    conditions = filter_opt.values.map { |value| "#{filter_opt.type} LIKE ?" }.join(" OR ")
                    like_values = filter_opt.values.map { |value| "%#{value}%" }
                  end
                  items = items.where(conditions, *like_values)
                end
              end

              if sort_opts.present?
                sort_opts.each do |sort_opt|
                  items = items.order("#{sort_opt.type} #{sort_opt.direction}")
                end
              else
                items = items.order("created_at desc")
              end

              pagyer, records = pagy(items, { page: page, items: per })
              records = records.map do |record|
                record_hash = record.attributes
                record_hash["application_type"] = application_type
                OpenStruct.new(record_hash)
              end
              return { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
            end
            { count: 0, total_page: 1, page: page, items: items }
          end

        end
      end
    end
  end
end
