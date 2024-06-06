# frozen_string_literal: true

module Types
  module Queries
      class SubjectCustomizationListQuery < BaseQuery

        type [Types::Meta::SubjectCustomizationType], null: true
        description 'Get subject customization list'

        def resolve
          current_user = context[:current_user]
          login_required!(current_user)

          if current_user&.is_admin?
            Subject.joins(:subject_customization)
                   .select("subjects.*, subject_customizations.name")
          else
            Subject.joins(:subject_customization, :subject_access_levels)
                   .where("subject_access_levels.user_id = ?", current_user.id)
                   .select("DISTINCT subjects.*, subject_customizations.name")
          end
        end
      end
  end
end
