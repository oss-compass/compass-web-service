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

    class BranchProtectionDetail < Grape::Entity
      expose :main_branch, documentation: { type: 'Array[String]', desc: 'main_branch', example: [], is_array: true }
      expose :release_branch, documentation: { type: 'Array[String]', desc: 'release_branch', example: [], is_array: true }
    end

    class CIIBestPracticesDetail < Grape::Entity
      expose :badge_level, documentation: { type: 'String', desc: 'badge_level', example: '' }
    end

    class DangerousWorkflowDetail < Grape::Entity
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :file, documentation: { type: 'String', desc: 'file', example: '' }
      expose :line, documentation: { type: 'String', desc: 'line', example: '' }
      expose :snippet, documentation: { type: 'String', desc: 'snippet', example: '' }
    end

    class FuzzingDetail < Grape::Entity
      expose :tool, documentation: { type: 'String', desc: 'tool', example: '' }
      expose :found, documentation: { type: 'String', desc: 'found', example: '' }
      expose :files, documentation: { type: 'String', desc: 'files', example: '' }
    end

    class PackagingDetail < Grape::Entity
      expose :matched, documentation: { type: 'String', desc: 'matched', example: '' }
      expose :file_path, documentation: { type: 'String', desc: 'file_path', example: '' }
      expose :line_number, documentation: { type: 'String', desc: 'line_number', example: '' }
    end

    class SASTDetail < Grape::Entity
      expose :sast_workflows, documentation: { type: 'String', desc: 'sast_workflows', example: '' }
      expose :sonar_configs, documentation: { type: 'String', desc: 'sonar_configs', example: '' }
    end

    class BBOMDetail < Grape::Entity
      expose :release_list, documentation: { type: 'String', desc: 'release_list', example: '' }
      expose :sbom_release_list, documentation: { type: 'String', desc: 'sbom_release_list', example: '' }
    end

    class ScorecardResponse < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "9497744d49ae8c0eba2b657d55a178a4b12c2b77" }
      expose :level, documentation: { type: 'String', desc: 'level', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'type', example: '' }
      expose :label, documentation: { type: 'String', desc: 'label', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'model_name', example: "Scorecard" }

      expose :score, documentation: { type: 'Float', desc: 'score of scorecard metric model', example: 10}
      expose :binary_artifacts, documentation: { type: 'Float', desc: 'Is the project free of checked-in binaries?', example: 10 }
      # expose :binary_artifacts_detail, documentation: { type: 'Array[String]', desc: 'binary artifact list', example: [], is_array: true }
      expose :branch_protection, documentation: { type: 'Float', desc: 'Does the project use Branch Protection', example: 10 }
      # expose :branch_protection_detail, using: Entities::BranchProtectionDetail, documentation: { type: 'Entities::BranchProtectionDetail', desc: 'branch protection details detail', param_type: 'body' }
      expose :ci_tests, documentation: { type: 'Float', desc: 'Does the project use Branch Protection', example: 10 }
      expose :cii_best_practices, documentation: { type: 'Float', desc: 'OpenSSF (formerly CII) Best Practices Badge', example: 10 }
      # expose :cii_best_practices_detail, using: Entities::CIIBestPracticesDetail, documentation: { type: 'Entities::CIIBestPracticesDetail', desc: 'cii best practices detail', param_type: 'body' }
      expose :code_review, documentation: { type: 'Float', desc: 'Does the project conduct code review before merging code?', example: 10 }
      # expose :code_review_detail, using: Entities::CodeReviewDetail, documentation: { type: 'Entities::CodeReviewDetail', desc: 'code review detail', param_type: 'body' }
      expose :contributors, documentation: { type: 'Float', desc: 'Does the project have contributors from at least two different organizations?', example: 10 }
      # expose :contributors_detail, documentation: { type: 'Array[String]', desc: 'org list', example: [], is_array: true }
      expose :dangerous_workflow, documentation: { type: 'Float', desc: 'dangerous workflow', example: 10 }
      # expose :dangerous_workflow_detail, using: Entities::DangerousWorkflowDetail, documentation: { type: 'Entities::DangerousWorkflowDetail', desc: 'dangerous workflow detail', param_type: 'body' }
      expose :dependency_update_tool, documentation: { type: 'Float', desc: 'dependency update tool', example: 10 }
      expose :fuzzing, documentation: { type: 'Float', desc: 'fuzzing', example: 10 }
      # expose :fuzzing_detail, using: Entities::FuzzingDetail, documentation: { type: 'Entities::FuzzingDetail', desc: 'fuzzing detail', param_type: 'body' }
      expose :license, documentation: { type: 'Float', desc: 'Does the project declare a license?', example: 10 }
      # expose :license_detail, using: Entities::LicenseDetail, documentation: { type: 'Entities::LicenseDetail', desc: 'license detail', param_type: 'body' }
      expose :maintained, documentation: { type: 'Float', desc: 'Is the project at least 90 days old, and maintained?', example: 10 }
      # expose :maintained_detail, using: Entities::MaintainedDetail, documentation: { type: 'Entities::MaintainedDetail', desc: 'maintained detail', param_type: 'body' }
      expose :packaging, documentation: { type: 'Float', desc: 'packaging', example: 10 }
      # expose :packaging_detail, using: Entities::PackagingDetail, documentation: { type: 'Entities::PackagingDetail', desc: 'packaging detail', param_type: 'body' }
      expose :pinned_dependencies, documentation: { type: 'Float', desc: 'pinned_dependencies', example: 10 }
      expose :sast, documentation: { type: 'Float', desc: 'sast', example: 10 }
      # expose :sast_detail, using: Entities::SASTDetail, documentation: { type: 'Entities::SASTDetail', desc: 'sast detail', param_type: 'body' }
      expose :sbom, documentation: { type: 'Float', desc: 'sbom', example: 10 }
      # expose :sbom_detail, using: Entities::BBOMDetail, documentation: { type: 'Entities::BBOMDetail', desc: 'sbom detail', param_type: 'body' }
      expose :security_policy, documentation: { type: 'Float', desc: 'security policy', example: 10 }
      expose :signed_releases, documentation: { type: 'Float', desc: 'Does the project cryptographically sign releases?', example: 10 }
      # expose :signed_releases_detail, using: Entities::SignedReleasesDetail, documentation: { type: 'Entities::SignedReleasesDetail', desc: 'signed releases detail', param_type: 'body' }
      expose :token_permissions, documentation: { type: 'Float', desc: 'token permissions', example: 10 }
      expose :vulnerabilities, documentation: { type: 'Float', desc: 'Does the project have unfixed vulnerabilities?', example: 10 }
      # expose :vulnerabilities_detail, using: Entities::VulnerabilitiesDetail, documentation: { type: 'Entities::VulnerabilitiesDetail', desc: 'vulnerabilities detail', param_type: 'body' }
      expose :webhooks, documentation: { type: 'Float', desc: 'webhooks', example: 10 }

      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2024-01-17T22:47:46.075025+00:00" }

    end

  end
end
