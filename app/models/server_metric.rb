# == Schema Information
#
# Table name: server_metrics
#
#  id             :bigint           not null, primary key
#  server_id      :string(255)      not null
#  cpu_percent    :float(24)
#  memory_percent :float(24)
#  disk_percent   :float(24)
#  disk_io_read   :float(24)
#  disk_io_write  :float(24)
#  net_io_recv    :float(24)
#  net_io_sent    :float(24)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ServerMetric < ApplicationRecord
end
