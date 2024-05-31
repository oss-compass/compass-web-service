# frozen_string_literal: true

module Types
  module Queries
      class SubjectSigPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Meta::SubjectSigPageType, null: true
        description 'Get subject sig data of my lab models'
        argument :label, String, required: true, description: 'repo or project label'
        argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(label: nil, level: 'repo', page: 1, per: 9)
          current_user = context[:current_user]
          login_required!(current_user)

          items = SubjectSig.joins(subject_ref: :parent)
                            .where("subjects.label = ? And subjects.`level` = ? And subject_refs.sub_type = ?",
                                   label, level, SubjectRef::ToSig)

          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
  end
end
