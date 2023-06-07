# == Schema Information
#
# Table name: subjects
#
#  id                :bigint           not null, primary key
#  label             :string(255)      not null
#  level             :string(255)      default("repo"), not null
#  status            :string(255)      default("pending"), not null
#  count             :integer          default(0), not null
#  status_updated_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  collect_at        :datetime
#  complete_at       :datetime
#
# Indexes
#
#  index_subjects_on_label  (label) UNIQUE
#
require 'rails_helper'

RSpec.describe Subject, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
