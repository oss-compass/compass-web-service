# frozen_string_literal: true

module Openapi
  module SharedParams
    module RepoUrl
      def normalize_incoming_repo_url!(url)
        TpcSoftwareMetricServer.normalize_repo_url(url)
      rescue GraphQL::ExecutionError
        error!(I18n.t('tpc.software_code_url_invalid'), 400)
      end
    end
  end
end
