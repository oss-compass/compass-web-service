# frozen_string_literal: true

module Mutations
  module Tpc
    class UpdateTpcSoftwareSandboxReport < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :report_id, Integer, required: true
      argument :software_report, Input::TpcSoftwareSandboxReportUpdateInput, required: true

      def resolve(report_id: nil, software_report: nil)
        current_user = context[:current_user]
        login_required!(current_user)

        sandbox_report = TpcSoftwareSandboxReport.find_by(id: report_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if sandbox_report.nil?
        raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || sandbox_report.user_id == current_user.id

        ActiveRecord::Base.transaction do
          sandbox_report.update!(software_report.as_json(except: [:architecture_diagrams]))

          architecture_diagrams = software_report.architecture_diagrams || []
          new_images = architecture_diagrams.select{ |image| !image.base64.starts_with?('/files') }
          keep_images = architecture_diagrams.select{ |image| image.base64.starts_with?('/files') }.map(&:id).compact

          raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if keep_images.length + new_images.length > 5

          if keep_images.present?
            diagrams_to_delete = sandbox_report.architecture_diagrams.where.not(id: keep_images)
            diagrams_to_delete.each do |diagram|
              diagram.purge
            end
          else
            sandbox_report.architecture_diagrams.purge
          end

          if new_images.present?
            diagrams_to_attach = new_images.map do |architecture_diagram|
              {
                data: architecture_diagram.base64,
                filename: architecture_diagram.filename
              }
            end
            sandbox_report.architecture_diagrams.attach(diagrams_to_attach)
          end
        end

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
