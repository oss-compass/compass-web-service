# frozen_string_literal: true
module Openapi
  module SharedParams

    module ErrorHelpers

      def handle_open_search_error(e)
        if e.message.include?("Result window is too large")
          Rails.logger.error "OpenSearch 分页错误: #{e.message}"
          error!(
            {
              error: "分页参数过大",
              message: "当前请求的分页数据量超出系统限制（最大 10000 条），请缩小时间范围或使用更精确的筛选条件"
            },
            400
          )
        else
          Rails.logger.error "OpenSearch 通用错误: #{e.message}"
          error!(
            {
              error: "数据查询失败",
              message: "搜索引擎服务暂时不可用"
            },
            500
          )
        end
      end

      def handle_generic_error(e)
        Rails.logger.error "系统 通用错误: #{e.message}"
        error!({
                 error: "internal_server_error",
                 message: "系统发生意外错误"
               },
               500
        )
      end

      def handle_release_error(e)
        Rails.logger.error "release error: #{e.message}"
        error!({
                 error: "version number error",
                 message: "#{e.message}"
               },
               500
        )
      end

      def handle_validation_error(e)
        Rails.logger.error "参数校验错误 : #{e.message}"
        error_messages = e.full_messages.map do |msg|
          field = msg[/^(.*?) /, 1]
          {
            field: field.downcase,
            message: msg
          }
        end
        error!({
                 error: "invalid_parameters",
                 details: error_messages
               },
               400
        )
      end

    end
  end
end
