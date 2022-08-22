# == Schema Information
#
# Table name: projects
#
#  id                :bigint           not null, primary key
#  name              :string(255)
#  language          :string(255)
#  hash              :string(255)
#  path              :string(255)
#  backend           :string(255)
#  html_url          :string(255)
#  forks_count       :integer
#  watchers_count    :integer
#  stargazers_count  :integer
#  open_issues_count :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Project < ApplicationRecord
end
