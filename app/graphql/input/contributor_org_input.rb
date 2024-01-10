# frozen_string_literal: true

module Input
  class ContributorOrgInput < Types::BaseInputObject
    argument :org_name, String, description: "organization's name"
    argument :first_date, GraphQL::Types::ISO8601DateTime, description: 'time of begin of service by the organization'
    argument :last_date, GraphQL::Types::ISO8601DateTime, description: 'time of end of service by the organization'

    def self.validate_no_overlap(inputs)
      ranges = inputs.map do |i|
        if i.last_date < i.first_date
          raise GraphQL::ExecutionError.new I18n.t('contributor_orgs.range_invalid')
        end
        (i.first_date..i.last_date)
      end

      overlaps = ranges.combination(2).any? { |r1, r2| (r1.min..r1.max).overlaps?(r2.min..r2.max) }
      if overlaps
        raise GraphQL::ExecutionError.new I18n.t('contributor_orgs.range_overlap')
      end
    end
  end
end
