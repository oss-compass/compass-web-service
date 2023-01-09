module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    field :message, String, null: true, camelize: false
    field :errors, [Types::ErrorType],
          null: true,
          description: 'Errors encountered during execution of the mutation.'

    def normalize_label(label)
      if label =~ URI::regexp
        uri = Addressable::URI.parse(label)
        "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}"
      else
        label
      end
    end
  end
end
