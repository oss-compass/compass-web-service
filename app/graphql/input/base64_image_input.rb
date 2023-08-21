# frozen_string_literal: true

module Input
  class Base64ImageInput < Types::BaseInputObject
    argument :id, Integer, required: false, description: 'image id'
    argument :filename, String, required: true, description: 'image filename'
    argument :base64, String, required: true, description: 'image base64 data, To attach base64 data it is required to come in the form of Data URIs, eg: data:image/png;base64,[base64 data]'
  end
end
