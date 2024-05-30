# frozen_string_literal: true

module Types
  module Meta
    class SubjectAccessLevelType < Types::BaseObject
      field :id, Integer, null: false
      field :subject_id, Integer, null: false
      field :access_level, Integer, null: false, description: 'NORMAL/COMMITTER: 0, PRIVILEGED/LEADER: 1'
      field :user_id, Integer, null: false
      field :user, Types::UserType

      def user
        User.find_by(id: object.user_id)
      end

    end
  end
end
