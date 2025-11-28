# == Schema Information
#
# Table name: star_project_participants
#
#  id                       :bigint           not null, primary key
#  star_project_id          :integer          not null
#  product_line             :string(255)
#  participant_account_name :string(255)
#  participant_company_id   :string(255)
#  related_email            :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
class StarProjectParticipant < ApplicationRecord
  belongs_to :star_project
end
