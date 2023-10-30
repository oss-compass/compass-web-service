# frozen_string_literal: true

module Input
  class FilterOptionInput < Types::BaseInputObject
    argument :type, String, required: true, description: 'filter option type'
    argument :value, String, required: true, description: 'filter option value'
  end
end
