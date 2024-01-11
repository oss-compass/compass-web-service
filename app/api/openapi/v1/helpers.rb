# frozen_string_literal: true

module Openapi
  module V1::Helpers
    include Common
    include CompassUtils
    include ContributorEnrich

    def current_user
      @current_user ||=
        if request.env['warden'].authenticate?
          request.env['warden'].user
        end
    end

    def validate_by_label!(label)
      return if current_user&.is_admin?
      if RESTRICTED_LABEL_LIST.include?(label) && !RESTRICTED_LABEL_VIEWERS.include?(current_user&.id.to_s)
        error!(I18n.t('users.forbidden'), 401)
      end
    end

    def validate_date!(label, level, begin_date, end_date)
        ok, valid_range = validate_date(current_user, label, level, begin_date, end_date)
        return if ok
        error!(I18n.t('basic.invalid_range', param: '`begin_date` or `end_date`', min: valid_range[0], max: valid_range[1]), 401)
      end
  end
end
