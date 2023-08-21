# frozen_string_literal: true

module Types
  class ImageType < Types::BaseObject
    include Rails.application.routes.url_helpers
    include Censoring

    censoring img: [:real_url]

    field :id, Integer, null: false
    field :url, String, null: false
    field :filename, String, null: false

    def url
      real_url_after_reviewed
    end

    def id
      object&.id
    end

    private
    def real_url
      rails_blob_path(object, only_path: true)
    end
  end
end
