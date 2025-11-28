# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSandboxReportPageQuery < BaseQuery
        include Pagy::Backend

        # type Types::Tpc::TpcSoftwareSelectionReportPageType, null: true
        type Types::Tpc::TpcSoftwareSandboxReportPageType, null: true
        description 'Get tpc software sandbox report apply page'
        argument :label, String, required: false, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or project level(repo/community)'
        argument :report_type_list, [Integer], required: true, description: 'incubation: 0, sandbox: 1, graduation: 2'
        # argument :report_category_list, [Integer], required: false, description: 'report category incubation: 0, selection: 2'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'
        argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
        argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'

        def resolve(label: nil, level: nil, report_type_list: [], page: 1, per: 9, filter_opts: nil, sort_opts: nil)
          subject = Subject.find_by(label: label, level: level)

          items = []
          if subject.present?
            items = TpcSoftwareSandboxReport.joins(:tpc_software_sandbox_report_metrics, :user)
                                              .where("tpc_software_sandbox_reports.subject_id = ?
                                                      And tpc_software_sandbox_reports.report_type IN (?)
                                                      And tpc_software_sandbox_report_metrics.version = ?",
                                                     subject.id, report_type_list, TpcSoftwareReportMetric::Version_Default)
            if filter_opts.present?
              filter_opts.each do |filter_opt|
                if filter_opt.type == "status"
                  conditions = filter_opt.values.map { |value| "tpc_software_sandbox_report_metrics.#{filter_opt.type} = ?" }.join(" OR ")
                  like_values = filter_opt.values.map { |value| "#{value}" }
                elsif filter_opt.type == "report_category"
                  conditions = "tpc_software_sandbox_reports.#{filter_opt.type} IN (?)"
                  like_values = [filter_opt.values]
                elsif filter_opt.type == "user"
                  conditions = filter_opt.values.map { |value| "users.name LIKE ?" }.join(" OR ")
                  like_values = filter_opt.values.map { |value| "%#{value}%" }
                else
                  conditions = filter_opt.values.map { |value| "tpc_software_sandbox_reports.#{filter_opt.type} LIKE ?" }.join(" OR ")
                  like_values = filter_opt.values.map { |value| "%#{value}%" }
                end
                items = items.where(conditions, *like_values)
              end
            end
            if sort_opts.present?
              sort_opts.each do |sort_opt|
                if ["created_at", "updated_at"].include?(sort_opt.type)
                  items = items.order("tpc_software_sandbox_report_metrics.#{sort_opt.type} #{sort_opt.direction}")
                end
              end
            else
              items = items.order("tpc_software_sandbox_report_metrics.updated_at desc")
            end
          end

          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
    end
  end
end
