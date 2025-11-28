# == Schema Information
#
# Table name: star_projects
#
#  id           :bigint           not null, primary key
#  project_name :string(255)
#  repo_url     :string(255)
#  main_osdt    :string(255)
#  remarks      :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class StarProject < ApplicationRecord
  has_many :star_project_participants , dependent: :destroy
end
