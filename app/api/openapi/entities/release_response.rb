# frozen_string_literal: true
module Openapi
  module Entities

    class ReleaseItem < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "46ffbafe9d42e2d02e646d7ed7aeb2bd71bb3bb1" }
      expose :id, documentation: { type: 'Integer', desc: 'id', example: 2456492 }
      expose :tag, documentation: { type: 'String', desc: 'tag', example: "https://github.com/spinnaker/spinnaker" }
      expose :tag_name, documentation: { type: 'String', desc: 'tag_name', example: "v0.20.0" }
      expose :target_commitish, documentation: { type: 'String', desc: 'target_commitish', example: "master" }
      expose :prerelease, documentation: { type: 'Boolean', desc: 'prerelease', example: false }
      expose :name, documentation: { type: 'String', desc: 'name', example: "Release via Travis CI" }
      expose :author_login, documentation: { type: 'String', desc: 'author_login', example: "tomaslin" }
      expose :author_name, documentation: { type: 'String', desc: 'author_name', example: "" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2016-01-19T19:39:06Z" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2023-03-21T05:38:31.602720+00:00" }

    end

    class ReleaseResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::ReleaseItem, documentation: { type: 'Entities::ReleaseItem', desc: 'response',
                                                                    param_type: 'body', is_array: true }
    end

  end
end
