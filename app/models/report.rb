# == Schema Information
#
# Table name: reports
#
#  id              :bigint           not null, primary key
#  content         :text(65535)
#  lang            :string(255)
#  associated_id   :string(255)
#  associated_type :string(255)
#  extra           :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Report < ApplicationRecord
end
