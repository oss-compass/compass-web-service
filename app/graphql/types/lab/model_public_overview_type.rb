# frozen_string_literal: true

module Types
  module Lab
    class ModelPublicOverviewType < BaseObject
      field :model_id, Integer
      field :model_name, String
      field :version_id, Integer
      field :version, String
      # field :dataset, DatasetType
      field :metrics, [ModelMetricType]
      field :dimension, Integer
      field :reports, [SimpleReportType]
      field :loginBinds, Types::LoginBindType
      field :created_at, GraphQL::Types::ISO8601DateTime


      def reports
        today = Date.today.end_of_day
        begin_date = today - 3.months
        end_date = today
        resp = CustomV1Metric.query_by_model_and_version(model_id, version_id, begin_date, end_date)
        build_simple_report_data(resp)
      end

      # def dataset
      #   model_version.dataset
      # end

      def model_id
        model.id
      end

      def dimension
        model.dimension
      end

      def version_id
        model_version.id
      end

      def version
        model_version.version
      end

      def model_name
        model.name
      end

      def metrics
        model_version.metrics
      end

      def loginBinds
        LoginBind.find_by(user_id: model.user_id)
      end

      private
      def build_simple_report_data(aggs)
        reports = aggs&.fetch('reports', {})&.fetch('buckets', [])
        skeletons = []
        reports.each do |report|
          hits = report.fetch('docs', {})&.fetch('hits', [])&.fetch('hits', [])
          values = []
          dates = []
          hits.each do |hit|
            dates << hit['_source']['grimoire_creation_date']
            values << hit['_source']['score']
          end
          skeletons << {
            label: report['key'],
            level: 'repo',
            short_code: ShortenedLabel.convert(report['key'], 'repo'),
            type: nil,
            main_score: { tab_ident: 'score', type: 'line', dates: dates, values: values }
          }
        end
        skeletons
      end

      def model
        @model ||= object
      end

      def model_version
        @model_version ||= model.default_version
      end
    end
  end
end
