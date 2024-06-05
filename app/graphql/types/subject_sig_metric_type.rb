# frozen_string_literal: true

module Types
  class SubjectSigMetricType < Types::BaseObject
    field :sig_name, String
    field :label, String
    field :level, String
    field :detail_list, [Types::SubjectSigMetricDetailType]
  end
end
