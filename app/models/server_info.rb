# == Schema Information
#
# Table name: server_infos
#
#  id                :bigint           not null, primary key
#  server_id         :string(255)      not null
#  hostname          :string(255)
#  ip_address        :string(255)
#  location          :string(255)
#  status            :string(255)
#  use_for           :string(255)
#  belong_to         :string(255)
#  cpu_info          :string(255)
#  memory_info       :string(255)
#  storage_info      :string(255)
#  net_info          :string(255)
#  system_info       :string(255)
#  architecture_info :string(255)
#  description       :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class ServerInfo < ApplicationRecord
end
