# frozen_string_literal: true
module Openapi
  module SharedParams
    module Utils
      def self.format_duration(ms)
        total_seconds = (ms / 1000).to_i  # 取整
        minutes = total_seconds / 60
        seconds = total_seconds % 60
        "#{minutes}分#{seconds}秒"
      end
    end
  end
end
