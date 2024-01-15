# frozen_string_literal: true

module Openapi
  class Callback

    def self.on_each(args)
      args[:source]
    end

    def self.on_finish(args)
      blob = ActiveStorage::Attachment.find_by(blob_id: args[:blob_id], name: 'exports')
      if blob
        Rails.cache.write(
          "export-#{args[:uuid]}",
          {
            status: ::Subject::COMPLETE,
            downdload_path: Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
          }
        )
      else
        Rails.cache.write("export-#{args[:uuid]}", { status: ::Subject::UNKNOWN })
      end
    end
  end
end
