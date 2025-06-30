# frozen_string_literal: true
module Openapi
  module Entities

    class CodeReviewDetail < Grape::Entity
      expose :recent_pr_count, documentation: { type: 'Integer', desc: 'The latest number of merged PRs', example: 30 }
      expose :recent_code_review_count, documentation: { type: 'Integer', desc: 'The number of newly merged PRs that have been reviewed', example: 30 }
    end

    class LicenseDetail < Grape::Entity
      expose :license_path, documentation: { type: 'String', desc: 'license path', example: "" }
      expose :license_name, documentation: { type: 'String', desc: 'license name', example: "" }
      expose :fsf_or_osi, documentation: { type: 'String', desc: ' FSF or OSI license is specified', example: "" }
    end

    class MaintainedDetail < Grape::Entity
      expose :commit_count, documentation: { type: 'Float', desc: 'commit count', example: 10 }
      expose :issue_count, documentation: { type: 'Float', desc: 'issue count', example: 10 }
    end

    class SignedReleasesDetail < Grape::Entity
      expose :release_list, documentation: { type: 'Array[String]', desc: 'release list', example: [], is_array: true}
      expose :signed_release_list, documentation: { type: 'Float', desc: 'signed issue count', example: [], is_array: true }
    end

    class VulnerabilitiesDetail < Grape::Entity
      expose :package_name, documentation: { type: 'String', desc: 'package name', example: ''}
      expose :vulnerabilities, documentation: { type: 'Array[String]', desc: 'vulnerabilities', example: [], is_array: true }
    end
    class ScorecardResponse < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "9497744d49ae8c0eba2b657d55a178a4b12c2b77" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Scorecard" }

      expose :binary_artifacts, documentation: { type: 'Float', desc: 'Is the project free of checked-in binaries?', example: 10 }
      expose :binary_artifacts_detail, documentation: { type: 'Array[String]', desc: 'binary artifact list', example: [], is_array: true }
      expose :code_review, documentation: { type: 'Float', desc: 'Does the project conduct code review before merging code?', example: 10 }
      expose :code_review_detail, using: Entities::CodeReviewDetail, documentation: { type: 'Entities::CodeReviewDetail', desc: 'code review detail', param_type: 'body' }
      expose :contributors, documentation: { type: 'Float', desc: 'Does the project have contributors from at least two different organizations?', example: 10 }
      expose :contributors_detail, documentation: { type: 'Array[String]', desc: 'org list', example: [], is_array: true }
      expose :license, documentation: { type: 'Float', desc: 'Does the project declare a license?', example: 10 }
      expose :license_detail, using: Entities::LicenseDetail, documentation: { type: 'Entities::LicenseDetail', desc: 'license detail', param_type: 'body' }
      expose :maintained, documentation: { type: 'Float', desc: 'Is the project at least 90 days old, and maintained?', example: 10 }
      expose :maintained_detail, using: Entities::MaintainedDetail, documentation: { type: 'Entities::MaintainedDetail', desc: 'maintained detail', param_type: 'body' }
      expose :signed_releases, documentation: { type: 'Float', desc: 'Does the project cryptographically sign releases?', example: 10 }
      expose :signed_releases_detail, using: Entities::SignedReleasesDetail, documentation: { type: 'Entities::SignedReleasesDetail', desc: 'signed releases detail', param_type: 'body' }
      expose :vulnerabilities, documentation: { type: 'Float', desc: 'Does the project have unfixed vulnerabilities?', example: 10 }
      expose :vulnerabilities_detail, using: Entities::VulnerabilitiesDetail, documentation: { type: 'Entities::VulnerabilitiesDetail', desc: 'vulnerabilities detail', param_type: 'body' }

      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2024-01-17T22:47:46.075025+00:00" }

    end

  end
end
