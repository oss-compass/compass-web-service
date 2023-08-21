# frozen_string_literal: true

module Input
  class LabModelMetricInput < Types::BaseInputObject
    argument :id, Integer, required: true, description: 'lab model metric id'
    argument :version_id, Integer, required: false, description: 'lab model version, default: latest version'
    argument :weight, Float, required: true, description: 'lab model metric weight'
    argument :threshold, Float, required: true, description: 'lab model metric threshold'
  end
end
