# frozen_string_literal: true

module Types
  module Meta
    class SubjectLinkSigType < Types::BaseObject
      field :label, String, description: 'metric model object identification'
      field :level, String, description: 'metric model object level (project or repo)'
      field :repos, [String]

      def repos
        subjects = Subject.joins(:subject_refs_as_child)
                          .where("subject_refs.parent_id = ?", object.id)
        subjects.map { |data| data.label  }
      end
    end
  end
end
