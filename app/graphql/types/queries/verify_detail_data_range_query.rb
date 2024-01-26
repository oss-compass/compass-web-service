# frozen_string_literal: true

module Types
  module Queries
    class VerifyDetailDataRangeQuery < BaseQuery
      type ValidDataRangeType, null: false
      description "Check if the data range is valid"

      argument :label, String, required: false, description: 'repo or project label'
      argument :short_code, String, required: false, description: 'repo or project short code'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, short_code: nil, begin_date: nil, end_date: nil)

        current_user = context[:current_user]

        login_required!(current_user)

        validate_by_label!(current_user, label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        label = ShortenedLabel.normalize_label(label) if label
        level = label =~ URI::regexp ? 'repo' : 'community' if label
        if short_code
          short = ShortenedLabel.revert(short_code)
          label = short&.label
          level = short&.level
        end

        ok, valid_range, label_admin = validate_date(current_user, label, level, begin_date, end_date)

        { status: ok, min: valid_range[0], max: valid_range[1], level: level, label: label, short_code: short_code, label_admin: label_admin }
      end
    end
  end
end
