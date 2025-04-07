# frozen_string_literal: true

module Types
  module Financial
    class VulPackageType < BaseObject

      field :package_name, String, null: true
      field :package_version, String, null: true
      field :severity, String, null: true
      field :vulnerabilities, [String], null: true

    end
  end
end
