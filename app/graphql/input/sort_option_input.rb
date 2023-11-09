# frozen_string_literal: true

module Input
  class SortOptionInput < Types::BaseInputObject
    argument :type, String, required: true, description: 'sort type value'
    argument :direction, String, required: true, description: 'sort direction, optional: desc, asc, default: desc'
  end
end
