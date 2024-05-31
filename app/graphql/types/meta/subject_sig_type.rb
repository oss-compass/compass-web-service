# frozen_string_literal: true

module Types
  module Meta
    class SubjectSigType < Types::BaseObject
      field :id, Integer, null: false
      field :name, String, null: false
      field :description, String, null: false
      field :maintainers, [String], null: false
      field :emails, [String], null: false
      field :link_sig, Types::Meta::SubjectLinkSigType


      def maintainers
        object.maintainers.present? ? JSON.parse(object.maintainers) : []
      end

      def emails
        object.emails.present? ? JSON.parse(object.emails) : []
      end

      def link_sig
        Subject.joins(subject_refs_as_child: :subject_sig)
               .where("subject_sigs.id = ?", object.id)
               .take
      end

    end
  end
end
