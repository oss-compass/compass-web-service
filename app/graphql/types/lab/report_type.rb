# frozen_string_literal: true

module Types
  module Lab
    class ReportType < SimpleReportType
      field :panels, [PanelType], description: 'metric panels data of lab model'
    end
  end
end
