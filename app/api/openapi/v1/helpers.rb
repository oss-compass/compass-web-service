# frozen_string_literal: true

module Openapi
  module V1::Helpers
    include Common
    include CompassUtils
    include ContributorEnrich

        # def current_user
    #   @current_user ||=
    #     if request.env['warden'].authenticate?
    #       request.env['warden'].user
    #     end
    # end
    #
    # def require_login!
    #   error!(I18n.t('users.require_login'), 400) unless current_user.present?
    # end

    def current_user
      @current_user ||= begin
                          # 记录当前收到的所有 Cookie 名称（不记录具体值，保护安全）
                          cookie_keys = request.cookies.keys.join(', ')
                          Rails.logger.info "[Auth_Debug] 正在检查登录态 | 路径: #{request.path} | 存在的 Cookies: [#{cookie_keys}]"

                          # 检查 Warden 环境是否存在
                          if request.env['warden'].nil?
                            Rails.logger.error "[Auth_Debug] 错误: request.env['warden'] 为空！检查中间件配置。"
                            return nil
                          end

                          # 执行 Warden 认证
                          if request.env['warden'].authenticate?
                            user = request.env['warden'].user
                            Rails.logger.info "[Auth_Debug] 认证成功: User ID = #{user&.id}"
                            user
                          else
                            Rails.logger.warn "[Auth_Debug] 认证失败: Warden 无法通过当前 Session/Cookie 识别用户。"
                            nil
                          end
                        end
    end

    def require_login!
      unless current_user.present?
        # 记录导致 400 错误的详细触发点
        Rails.logger.error "[Auth_Debug] 权限拒绝: current_user 为空，抛出 400 错误。"
        error!(I18n.t('users.require_login'), 400)
      end
    end


    def validate_by_label!(label)
      return if current_user&.is_admin?
      if RESTRICTED_LABEL_LIST.include?(label) && !RESTRICTED_LABEL_VIEWERS.include?(current_user&.id.to_s)
        error!(I18n.t('users.forbidden'), 401)
      end
    end

    def validate_date!(label, level, begin_date, end_date)
        ok, valid_range, _admin = validate_date(current_user, label, level, begin_date, end_date)
        return if ok
        error!(I18n.t('basic.invalid_range', param: '`begin_date` or `end_date`', min: valid_range[0], max: valid_range[1]), 401)
      end
  end
end
