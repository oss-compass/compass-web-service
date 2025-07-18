# frozen_string_literal: true
module Openapi
  module Entities

    class CiiBestBadgeResponse < Grape::Entity
      expose :id, documentation: { type: 'Float', desc: 'id / 唯一标识ID', example: 5621 }
      expose :user_id, documentation: { type: 'Float', desc: 'user_id / 用户ID', example: 17212 }
      expose :name, documentation: { type: 'String', desc: 'name / 项目名称', example: 'OpenSSF Scorecard' }
      expose :description, documentation: { type: 'String', desc: 'description / 项目描述', example: 'Scorecard is an automated tool that assesses a Float of important heuristics ("checks") associated with software security and assigns each check a score of 0-10. You can use these scores to understand specific areas to improve in order to strengthen the security posture of your project...' }
      expose :homepage_url, documentation: { type: 'String', desc: 'homepage_url / 项目主页URL', example: 'https://github.com/ossf/scorecard' }
      expose :repo_url, documentation: { type: 'String', desc: 'repo_url / 项目代码仓库URL', example: 'https://github.com/ossf/scorecard' }
      expose :license, documentation: { type: 'String', desc: 'license / 项目许可证', example: 'Apache-2.0' }
      expose :homepage_url_status, documentation: { type: 'String', desc: 'homepage_url_status / 主页URL状态', example: '' }
      expose :homepage_url_justification, documentation: { type: 'String', desc: 'homepage_url_justification / 主页URL状态说明', example: '' }
      expose :sites_https_status, documentation: { type: 'String', desc: 'sites_https_status / 站点HTTPS状态', example: 'Met' }
      expose :sites_https_justification, documentation: { type: 'String', desc: 'sites_https_justification / 站点HTTPS状态说明', example: 'Given only https: URLs.' }
      expose :description_good_status, documentation: { type: 'String', desc: 'description_good_status / 描述质量状态', example: 'Met' }
      expose :description_good_justification, documentation: { type: 'String', desc: 'description_good_justification / 描述质量状态说明', example: 'https://github.com/ossf/scorecard/blob/main/README.md' }
      expose :interact_status, documentation: { type: 'String', desc: 'interact_status / 交互状态', example: 'Met' }
      expose :interact_justification, documentation: { type: 'String', desc: 'interact_justification / 交互状态说明', example: 'https://github.com/ossf/scorecard/blob/main/CONTRIBUTING.md' }
      expose :contribution_status, documentation: { type: 'String', desc: 'contribution_status / 贡献状态', example: 'Met' }
      expose :contribution_justification, documentation: { type: 'String', desc: 'contribution_justification / 贡献状态说明', example: 'https://github.com/ossf/scorecard/blob/main/CONTRIBUTING.md' }
      expose :contribution_requirements_status, documentation: { type: 'String', desc: 'contribution_requirements_status / 贡献要求状态', example: 'Met' }
      expose :contribution_requirements_justification, documentation: { type: 'String', desc: 'contribution_requirements_justification / 贡献要求状态说明', example: 'https://github.com/ossf/scorecard/blob/main/CONTRIBUTING.md' }
      expose :license_location_status, documentation: { type: 'String', desc: 'license_location_status / 许可证位置状态', example: 'Met' }
      expose :license_location_justification, documentation: { type: 'String', desc: 'license_location_justification / 许可证位置状态说明', example: 'https://github.com/ossf/scorecard/blob/main/LICENSE' }
      expose :floss_license_status, documentation: { type: 'String', desc: 'floss_license_status / FLOSS许可证状态', example: 'Met' }
      expose :floss_license_justification, documentation: { type: 'String', desc: 'floss_license_justification / FLOSS许可证状态说明', example: 'The Apache-2.0 license is approved by the Open Source Initiative (OSI).' }
      expose :floss_license_osi_status, documentation: { type: 'String', desc: 'floss_license_osi_status / FLOSS许可证OSI认证状态', example: 'Met' }
      expose :floss_license_osi_justification, documentation: { type: 'String', desc: 'floss_license_osi_justification / FLOSS许可证OSI认证说明', example: 'The Apache-2.0 license is approved by the Open Source Initiative (OSI).' }
      expose :documentation_basics_status, documentation: { type: 'String', desc: 'documentation_basics_status / 基础文档状态', example: 'Met' }
      expose :documentation_basics_justification, documentation: { type: 'String', desc: 'documentation_basics_justification / 基础文档状态说明', example: 'Some documentation basics file contents found.' }
      expose :documentation_interface_status, documentation: { type: 'String', desc: 'documentation_interface_status / 接口文档状态', example: 'Met' }
      expose :documentation_interface_justification, documentation: { type: 'String', desc: 'documentation_interface_justification / 接口文档状态说明', example: 'https://api.securityscorecards.dev/' }
      expose :repo_public_status, documentation: { type: 'String', desc: 'repo_public_status / 仓库公开状态', example: 'Met' }
      expose :repo_public_justification, documentation: { type: 'String', desc: 'repo_public_justification / 仓库公开状态说明', example: 'Repository on GitHub, which provides public git repositories with URLs.' }
      expose :repo_track_status, documentation: { type: 'String', desc: 'repo_track_status / 仓库变更跟踪状态', example: 'Met' }
      expose :repo_track_justification, documentation: { type: 'String', desc: 'repo_track_justification / 仓库变更跟踪状态说明', example: 'Repository on GitHub, which uses git. git can track the changes, who made them, and when they were made.' }
      expose :repo_interim_status, documentation: { type: 'String', desc: 'repo_interim_status / 仓库临时版本状态', example: 'Met' }
      expose :repo_interim_justification, documentation: { type: 'String', desc: 'repo_interim_justification / 仓库临时版本状态说明', example: 'Tags: https://github.com/ossf/scorecard/tags' }
      expose :repo_distributed_status, documentation: { type: 'String', desc: 'repo_distributed_status / 仓库分布式状态', example: 'Met' }
      expose :repo_distributed_justification, documentation: { type: 'String', desc: 'repo_distributed_justification / 仓库分布式状态说明', example: 'Repository on GitHub, which uses git. git is distributed.' }
      expose :version_unique_status, documentation: { type: 'String', desc: 'version_unique_status / 版本唯一性状态', example: 'Met' }
      expose :version_unique_justification, documentation: { type: 'String', desc: 'version_unique_justification / 版本唯一性状态说明', example: '' }
      expose :version_semver_status, documentation: { type: 'String', desc: 'version_semver_status / 语义化版本状态', example: 'Met' }
      expose :version_semver_justification, documentation: { type: 'String', desc: 'version_semver_justification / 语义化版本状态说明', example: '' }
      expose :version_tags_status, documentation: { type: 'String', desc: 'version_tags_status / 版本标签状态', example: 'Met' }
      expose :version_tags_justification, documentation: { type: 'String', desc: 'version_tags_justification / 版本标签状态说明', example: '' }
      expose :release_notes_status, documentation: { type: 'String', desc: 'release_notes_status / 发布说明状态', example: 'Met' }
      expose :release_notes_justification, documentation: { type: 'String', desc: 'release_notes_justification / 发布说明状态说明', example: 'https://github.com/ossf/scorecard/releases' }
      expose :release_notes_vulns_status, documentation: { type: 'String', desc: 'release_notes_vulns_status / 发布说明漏洞状态', example: 'Met' }
      expose :release_notes_vulns_justification, documentation: { type: 'String', desc: 'release_notes_vulns_justification / 发布说明漏洞状态说明', example: '' }
      expose :report_url_status, documentation: { type: 'String', desc: 'report_url_status / 报告URL状态', example: '' }
      expose :report_url_justification, documentation: { type: 'String', desc: 'report_url_justification / 报告URL状态说明', example: '' }
      expose :report_tracker_status, documentation: { type: 'String', desc: 'report_tracker_status / 报告跟踪状态', example: 'Met' }
      expose :report_tracker_justification, documentation: { type: 'String', desc: 'report_tracker_justification / 报告跟踪状态说明', example: '' }
      expose :report_process_status, documentation: { type: 'String', desc: 'report_process_status / 报告流程状态', example: 'Met' }
      expose :report_process_justification, documentation: { type: 'String', desc: 'report_process_justification / 报告流程状态说明', example: 'https://github.com/ossf/scorecard/blob/main/CONTRIBUTING.md' }
      expose :report_responses_status, documentation: { type: 'String', desc: 'report_responses_status / 报告响应状态', example: 'Met' }
      expose :report_responses_justification, documentation: { type: 'String', desc: 'report_responses_justification / 报告响应状态说明', example: '' }
      expose :enhancement_responses_status, documentation: { type: 'String', desc: 'enhancement_responses_status / 增强请求响应状态', example: 'Met' }
      expose :enhancement_responses_justification, documentation: { type: 'String', desc: 'enhancement_responses_justification / 增强请求响应状态说明', example: '' }
      expose :report_archive_status, documentation: { type: 'String', desc: 'report_archive_status / 报告归档状态', example: 'Met' }
      expose :report_archive_justification, documentation: { type: 'String', desc: 'report_archive_justification / 报告归档状态说明', example: 'https://github.com/ossf/scorecard/issues' }
      expose :vulnerability_report_process_status, documentation: { type: 'String', desc: 'vulnerability_report_process_status / 漏洞报告流程状态', example: 'Met' }
      expose :vulnerability_report_process_justification, documentation: { type: 'String', desc: 'vulnerability_report_process_justification / 漏洞报告流程状态说明', example: 'https://github.com/ossf/scorecard/blob/main/SECURITY.md' }
      expose :vulnerability_report_private_status, documentation: { type: 'String', desc: 'vulnerability_report_private_status / 漏洞报告私密性状态', example: 'Met' }
      expose :vulnerability_report_private_justification, documentation: { type: 'String', desc: 'vulnerability_report_private_justification / 漏洞报告私密性状态说明', example: 'https://github.com/ossf/scorecard/blob/main/SECURITY.md' }
      expose :vulnerability_report_response_status, documentation: { type: 'String', desc: 'vulnerability_report_response_status / 漏洞报告响应状态', example: 'Met' }
      expose :vulnerability_report_response_justification, documentation: { type: 'String', desc: 'vulnerability_report_response_justification / 漏洞报告响应状态说明', example: '' }
      expose :build_status, documentation: { type: 'String', desc: 'build_status / 构建状态', example: 'Met' }
      expose :build_justification, documentation: { type: 'String', desc: 'build_justification / 构建状态说明', example: 'Non-trivial build file in repository: <https://github.com/ossf/scorecard/blob/main/Makefile>.' }
      expose :build_common_tools_status, documentation: { type: 'String', desc: 'build_common_tools_status / 通用构建工具状态', example: 'Met' }
      expose :build_common_tools_justification, documentation: { type: 'String', desc: 'build_common_tools_justification / 通用构建工具状态说明', example: 'Non-trivial build file in repository: <https://github.com/ossf/scorecard/blob/main/Makefile>.' }
      expose :build_floss_tools_status, documentation: { type: 'String', desc: 'build_floss_tools_status / FLOSS构建工具状态', example: 'Met' }
      expose :build_floss_tools_justification, documentation: { type: 'String', desc: 'build_floss_tools_justification / FLOSS构建工具状态说明', example: '' }
      expose :test_status, documentation: { type: 'String', desc: 'test_status / 测试状态', example: 'Met' }
      expose :test_justification, documentation: { type: 'String', desc: 'test_justification / 测试状态说明', example: '' }
      expose :test_invocation_status, documentation: { type: 'String', desc: 'test_invocation_status / 测试调用状态', example: 'Met' }
      expose :test_invocation_justification, documentation: { type: 'String', desc: 'test_invocation_justification / 测试调用状态说明', example: '' }
      expose :test_most_status, documentation: { type: 'String', desc: 'test_most_status / 主要测试覆盖状态', example: 'Met' }
      expose :test_most_justification, documentation: { type: 'String', desc: 'test_most_justification / 主要测试覆盖状态说明', example: '' }
      expose :test_policy_status, documentation: { type: 'String', desc: 'test_policy_status / 测试策略状态', example: 'Met' }
      expose :test_policy_justification, documentation: { type: 'String', desc: 'test_policy_justification / 测试策略状态说明', example: '' }
      expose :tests_are_added_status, documentation: { type: 'String', desc: 'tests_are_added_status / 新增测试状态', example: 'Met' }
      expose :tests_are_added_justification, documentation: { type: 'String', desc: 'tests_are_added_justification / 新增测试状态说明', example: '' }
      expose :tests_documented_added_status, documentation: { type: 'String', desc: 'tests_documented_added_status / 新增测试文档状态', example: 'Met' }
      expose :tests_documented_added_justification, documentation: { type: 'String', desc: 'tests_documented_added_justification / 新增测试文档状态说明', example: '' }
      expose :warnings_status, documentation: { type: 'String', desc: 'warnings_status / 警告处理状态', example: 'Met' }
      expose :warnings_justification, documentation: { type: 'String', desc: 'warnings_justification / 警告处理状态说明', example: 'Linters enabled: https://github.com/ossf/scorecard/blob/main/.github/workflows/lint.yml' }
      expose :warnings_fixed_status, documentation: { type: 'String', desc: 'warnings_fixed_status / 警告修复状态', example: 'Met' }
      expose :warnings_fixed_justification, documentation: { type: 'String', desc: 'warnings_fixed_justification / 警告修复状态说明', example: 'Linters enabled and blocking for code submissions: https://github.com/ossf/scorecard/blob/main/.github/workflows/lint.yml' }
      expose :warnings_strict_status, documentation: { type: 'String', desc: 'warnings_strict_status / 严格警告检查状态', example: 'Met' }
      expose :warnings_strict_justification, documentation: { type: 'String', desc: 'warnings_strict_justification / 严格警告检查状态说明', example: 'Linters enabled and blocking for code submissions: https://github.com/ossf/scorecard/blob/main/.github/workflows/lint.yml' }
      expose :know_secure_design_status, documentation: { type: 'String', desc: 'know_secure_design_status / 安全设计认知状态', example: 'Met' }
      expose :know_secure_design_justification, documentation: { type: 'String', desc: 'know_secure_design_justification / 安全设计认知状态说明', example: '' }
      expose :know_common_errors_status, documentation: { type: 'String', desc: 'know_common_errors_status / 常见错误认知状态', example: 'Met' }
      expose :know_common_errors_justification, documentation: { type: 'String', desc: 'know_common_errors_justification / 常见错误认知状态说明', example: '' }
      expose :crypto_published_status, documentation: { type: 'String', desc: 'crypto_published_status / 加密算法公开状态', example: 'Met' }
      expose :crypto_published_justification, documentation: { type: 'String', desc: 'crypto_published_justification / 加密算法公开状态说明', example: '' }
      expose :crypto_call_status, documentation: { type: 'String', desc: 'crypto_call_status / 加密调用状态', example: 'Met' }
      expose :crypto_call_justification, documentation: { type: 'String', desc: 'crypto_call_justification / 加密调用状态说明', example: '' }
      expose :crypto_floss_status, documentation: { type: 'String', desc: 'crypto_floss_status / FLOSS加密状态', example: 'Met' }
      expose :crypto_floss_justification, documentation: { type: 'String', desc: 'crypto_floss_justification / FLOSS加密状态说明', example: '' }
      expose :crypto_keylength_status, documentation: { type: 'String', desc: 'crypto_keylength_status / 加密密钥长度状态', example: 'Met' }
      expose :crypto_keylength_justification, documentation: { type: 'String', desc: 'crypto_keylength_justification / 加密密钥长度状态说明', example: '' }
      expose :crypto_working_status, documentation: { type: 'String', desc: 'crypto_working_status / 加密功能有效性状态', example: 'Met' }
      expose :crypto_working_justification, documentation: { type: 'String', desc: 'crypto_working_justification / 加密功能有效性状态说明', example: '' }
      expose :crypto_pfs_status, documentation: { type: 'String', desc: 'crypto_pfs_status / 完美前向保密状态', example: 'Met' }
      expose :crypto_pfs_justification, documentation: { type: 'String', desc: 'crypto_pfs_justification / 完美前向保密状态说明', example: '' }
      expose :crypto_password_storage_status, documentation: { type: 'String', desc: 'crypto_password_storage_status / 密码存储加密状态', example: 'N/A' }
      expose :crypto_password_storage_justification, documentation: { type: 'String', desc: 'crypto_password_storage_justification / 密码存储加密状态说明', example: '' }
      expose :crypto_random_status, documentation: { type: 'String', desc: 'crypto_random_status / 加密随机数状态', example: 'Met' }
      expose :crypto_random_justification, documentation: { type: 'String', desc: 'crypto_random_justification / 加密随机数状态说明', example: '' }
      expose :delivery_mitm_status, documentation: { type: 'String', desc: 'delivery_mitm_status / 传输中间人防护状态', example: 'Met' }
      expose :delivery_mitm_justification, documentation: { type: 'String', desc: 'delivery_mitm_justification / 传输中间人防护状态说明', example: '' }
      expose :delivery_unsigned_status, documentation: { type: 'String', desc: 'delivery_unsigned_status / 传输未签名状态', example: 'Met' }
      expose :delivery_unsigned_justification, documentation: { type: 'String', desc: 'delivery_unsigned_justification / 传输未签名状态说明', example: '' }
      expose :vulnerabilities_fixed_60_days_status, documentation: { type: 'String', desc: 'vulnerabilities_fixed_60_days_status / 60天内漏洞修复状态', example: 'Met' }
      expose :vulnerabilities_fixed_60_days_justification, documentation: { type: 'String', desc: 'vulnerabilities_fixed_60_days_justification / 60天内漏洞修复状态说明', example: '' }
      expose :vulnerabilities_critical_fixed_status, documentation: { type: 'String', desc: 'vulnerabilities_critical_fixed_status / 严重漏洞修复状态', example: 'Met' }
      expose :vulnerabilities_critical_fixed_justification, documentation: { type: 'String', desc: 'vulnerabilities_critical_fixed_justification / 严重漏洞修复状态说明', example: '' }
      expose :static_analysis_status, documentation: { type: 'String', desc: 'static_analysis_status / 静态分析状态', example: 'Met' }
      expose :static_analysis_justification, documentation: { type: 'String', desc: 'static_analysis_justification / 静态分析状态说明', example: 'CodeQL: https://github.com/ossf/scorecard/blob/main/.github/workflows/codeql-analysis.yml' }
      expose :static_analysis_common_vulnerabilities_status, documentation: { type: 'String', desc: 'static_analysis_common_vulnerabilities_status / 静态分析常见漏洞状态', example: 'Met' }
      expose :static_analysis_common_vulnerabilities_justification, documentation: { type: 'String', desc: 'static_analysis_common_vulnerabilities_justification / 静态分析常见漏洞状态说明', example: '' }
      expose :static_analysis_fixed_status, documentation: { type: 'String', desc: 'static_analysis_fixed_status / 静态分析问题修复状态', example: 'Met' }
      expose :static_analysis_fixed_justification, documentation: { type: 'String', desc: 'static_analysis_fixed_justification / 静态分析问题修复状态说明', example: '' }
      expose :static_analysis_often_status, documentation: { type: 'String', desc: 'static_analysis_often_status / 静态分析频率状态', example: 'Met' }
      expose :static_analysis_often_justification, documentation: { type: 'String', desc: 'static_analysis_often_justification / 静态分析频率状态说明', example: 'CodeQL blocking on code submissions: https://github.com/ossf/scorecard/blob/main/.github/workflows/codeql-analysis.yml' }
      expose :dynamic_analysis_status, documentation: { type: 'String', desc: 'dynamic_analysis_status / 动态分析状态', example: 'Met' }
      expose :dynamic_analysis_justification, documentation: { type: 'String', desc: 'dynamic_analysis_justification / 动态分析状态说明', example: '' }
      expose :dynamic_analysis_unsafe_status, documentation: { type: 'String', desc: 'dynamic_analysis_unsafe_status / 动态分析不安全操作状态', example: 'Met' }
      expose :dynamic_analysis_unsafe_justification, documentation: { type: 'String', desc: 'dynamic_analysis_unsafe_justification / 动态分析不安全操作状态说明', example: '' }
      expose :dynamic_analysis_enable_assertions_status, documentation: { type: 'String', desc: 'dynamic_analysis_enable_assertions_status / 动态分析断言启用状态', example: 'Met' }
      expose :dynamic_analysis_enable_assertions_justification, documentation: { type: 'String', desc: 'dynamic_analysis_enable_assertions_justification / 动态分析断言启用状态说明', example: '' }
      expose :dynamic_analysis_fixed_status, documentation: { type: 'String', desc: 'dynamic_analysis_fixed_status / 动态分析问题修复状态', example: 'Met' }
      expose :dynamic_analysis_fixed_justification, documentation: { type: 'String', desc: 'dynamic_analysis_fixed_justification / 动态分析问题修复状态说明', example: '' }
      expose :general_comments, documentation: { type: 'String', desc: 'general_comments / 通用评论', example: '' }
      expose :created_at, documentation: { type: 'String', desc: 'created_at / 创建时间', example: '2022-02-12T09:58:20.129Z' }
      expose :updated_at, documentation: { type: 'String', desc: 'updated_at / 更新时间', example: '2023-09-19T12:56:47.209Z' }
      expose :crypto_weaknesses_status, documentation: { type: 'String', desc: 'crypto_weaknesses_status / 加密弱点状态', example: 'Met' }
      expose :crypto_weaknesses_justification, documentation: { type: 'String', desc: 'crypto_weaknesses_justification / 加密弱点状态说明', example: '' }
      expose :test_continuous_integration_status, documentation: { type: 'String', desc: 'test_continuous_integration_status / 持续集成测试状态', example: 'Met' }
      expose :test_continuous_integration_justification, documentation: { type: 'String', desc: 'test_continuous_integration_justification / 持续集成测试状态说明', example: '' }
      expose :cpe, documentation: { type: 'String', desc: 'cpe / CPE标识', example: '' }
      expose :discussion_status, documentation: { type: 'String', desc: 'discussion_status / 讨论状态', example: 'Met' }
      expose :discussion_justification, documentation: { type: 'String', desc: 'discussion_justification / 讨论状态说明', example: 'GitHub supports discussions on issues and pull requests.' }
      expose :no_leaked_credentials_status, documentation: { type: 'String', desc: 'no_leaked_credentials_status / 无凭证泄露状态', example: 'Met' }
      expose :no_leaked_credentials_justification, documentation: { type: 'String', desc: 'no_leaked_credentials_justification / 无凭证泄露状态说明', example: '' }
      expose :english_status, documentation: { type: 'String', desc: 'english_status / 英文支持状态', example: 'Met' }
      expose :english_justification, documentation: { type: 'String', desc: 'english_justification / 英文支持状态说明', example: '' }
      expose :hardening_status, documentation: { type: 'String', desc: 'hardening_status / 硬化状态', example: '' }
      expose :hardening_justification, documentation: { type: 'String', desc: 'hardening_justification / 硬化状态说明', example: '' }
      expose :crypto_used_network_status, documentation: { type: 'String', desc: 'crypto_used_network_status / 网络加密使用状态', example: '' }
      expose :crypto_used_network_justification, documentation: { type: 'String', desc: 'crypto_used_network_justification / 网络加密使用状态说明', example: '' }
      expose :crypto_tls12_status, documentation: { type: 'String', desc: 'crypto_tls12_status / TLS 1.2加密状态', example: '' }
      expose :crypto_tls12_justification, documentation: { type: 'String', desc: 'crypto_tls12_justification / TLS 1.2加密状态说明', example: '' }
      expose :crypto_certificate_verification_status, documentation: { type: 'String', desc: 'crypto_certificate_verification_status / 证书验证状态', example: '' }
      expose :crypto_certificate_verification_justification, documentation: { type: 'String', desc: 'crypto_certificate_verification_justification / 证书验证状态说明', example: '' }
      expose :crypto_verification_private_status, documentation: { type: 'String', desc: 'crypto_verification_private_status / 私有验证加密状态', example: '' }
      expose :crypto_verification_private_justification, documentation: { type: 'String', desc: 'crypto_verification_private_justification / 私有验证加密状态说明', example: '' }
      expose :hardened_site_status, documentation: { type: 'String', desc: 'hardened_site_status / 站点硬化状态', example: 'Met' }
      expose :hardened_site_justification, documentation: { type: 'String', desc: 'hardened_site_justification / 站点硬化状态说明', example: 'Found all required security hardening headers.' }
      expose :installation_common_status, documentation: { type: 'String', desc: 'installation_common_status / 通用安装状态', example: '' }
      expose :installation_common_justification, documentation: { type: 'String', desc: 'installation_common_justification / 通用安装状态说明', example: '' }
      expose :build_reproducible_status, documentation: { type: 'String', desc: 'build_reproducible_status / 构建可复现性状态', example: '' }
      expose :build_reproducible_justification, documentation: { type: 'String', desc: 'build_reproducible_justification / 构建可复现性状态说明', example: '' }
      expose :badge_percentage_0, documentation: { type: 'Float', desc: 'badge_percentage_0 / 徽章百分比0', example: 100 }
      expose :achieved_passing_at, documentation: { type: 'String', desc: 'achieved_passing_at / 达到通过状态时间', example: '2023-09-19T12:56:47.208Z' }
      expose :lost_passing_at, documentation: { type: 'String', desc: 'lost_passing_at / 失去通过状态时间', example: '' }
      expose :last_reminder_at, documentation: { type: 'String', desc: 'last_reminder_at / 最后提醒时间', example: '2023-03-05T23:03:35.614Z' }
      expose :disabled_reminders, documentation: { type: 'Boolean', desc: 'disabled_reminders / 是否禁用提醒', example: false }
      expose :implementation_languages, documentation: { type: 'String', desc: 'implementation_languages / 实现语言', example: 'Go' }
      expose :lock_version, documentation: { type: 'Float', desc: 'lock_version / 锁定版本', example: 14 }
      expose :badge_percentage_1, documentation: { type: 'Float', desc: 'badge_percentage_1 / 徽章百分比1', example: 5 }
      expose :dco_status, documentation: { type: 'String', desc: 'dco_status / DCO状态', example: '' }
      expose :dco_justification, documentation: { type: 'String', desc: 'dco_justification / DCO状态说明', example: '' }
      expose :governance_status, documentation: { type: 'String', desc: 'governance_status / 治理状态', example: '' }
      expose :governance_justification, documentation: { type: 'String', desc: 'governance_justification / 治理状态说明', example: '' }
      expose :code_of_conduct_status, documentation: { type: 'String', desc: 'code_of_conduct_status / 行为准则状态', example: '' }
      expose :code_of_conduct_justification, documentation: { type: 'String', desc: 'code_of_conduct_justification / 行为准则状态说明', example: '' }
      expose :roles_responsibilities_status, documentation: { type: 'String', desc: 'roles_responsibilities_status / 角色职责状态', example: '' }
      expose :roles_responsibilities_justification, documentation: { type: 'String', desc: 'roles_responsibilities_justification / 角色职责状态说明', example: '' }
      expose :access_continuity_status, documentation: { type: 'String', desc: 'access_continuity_status / 访问连续性状态', example: '' }
      expose :access_continuity_justification, documentation: { type: 'String', desc: 'access_continuity_justification / 访问连续性状态说明', example: '' }
      expose :bus_factor_status, documentation: { type: 'String', desc: 'bus_factor_status / 核心贡献者风险状态', example: '' }
      expose :bus_factor_justification, documentation: { type: 'String', desc: 'bus_factor_justification / 核心贡献者风险状态说明', example: '' }
      expose :documentation_roadmap_status, documentation: { type: 'String', desc: 'documentation_roadmap_status / 路线图文档状态', example: '' }
      expose :documentation_roadmap_justification, documentation: { type: 'String', desc: 'documentation_roadmap_justification / 路线图文档状态说明', example: '' }
      expose :documentation_architecture_status, documentation: { type: 'String', desc: 'documentation_architecture_status / 架构文档状态', example: '' }
      expose :documentation_architecture_justification, documentation: { type: 'String', desc: 'documentation_architecture_justification / 架构文档状态说明', example: '' }
      expose :documentation_security_status, documentation: { type: 'String', desc: 'documentation_security_status / 安全文档状态', example: '' }
      expose :documentation_security_justification, documentation: { type: 'String', desc: 'documentation_security_justification / 安全文档状态说明', example: '' }
      expose :documentation_quick_start_status, documentation: { type: 'String', desc: 'documentation_quick_start_status / 快速入门文档状态', example: '' }
      expose :documentation_quick_start_justification, documentation: { type: 'String', desc: 'documentation_quick_start_justification / 快速入门文档状态说明', example: '' }
      expose :documentation_current_status, documentation: { type: 'String', desc: 'documentation_current_status / 文档时效性状态', example: '' }
      expose :documentation_current_justification, documentation: { type: 'String', desc: 'documentation_current_justification / 文档时效性状态说明', example: '' }
      expose :documentation_achievements_status, documentation: { type: 'String', desc: 'documentation_achievements_status / 成果文档状态', example: '' }
      expose :documentation_achievements_justification, documentation: { type: 'String', desc: 'documentation_achievements_justification / 成果文档状态说明', example: '' }
      expose :accessibility_best_practices_status, documentation: { type: 'String', desc: 'accessibility_best_practices_status / 无障碍最佳实践状态', example: '' }
      expose :accessibility_best_practices_justification, documentation: { type: 'String', desc: 'accessibility_best_practices_justification / 无障碍最佳实践状态说明', example: '' }
      expose :internationalization_status, documentation: { type: 'String', desc: 'internationalization_status / 国际化状态', example: '' }
      expose :internationalization_justification, documentation: { type: 'String', desc: 'internationalization_justification / 国际化状态说明', example: '' }
      expose :sites_password_security_status, documentation: { type: 'String', desc: 'sites_password_security_status / 站点密码安全状态', example: '' }
      expose :sites_password_security_justification, documentation: { type: 'String', desc: 'sites_password_security_justification / 站点密码安全状态说明', example: '' }
      expose :maintenance_or_update_status, documentation: { type: 'String', desc: 'maintenance_or_update_status / 维护或更新状态', example: '' }
      expose :maintenance_or_update_justification, documentation: { type: 'String', desc: 'maintenance_or_update_justification / 维护或更新状态说明', example: '' }
      expose :vulnerability_report_credit_status, documentation: { type: 'String', desc: 'vulnerability_report_credit_status / 漏洞报告致谢状态', example: '' }
      expose :vulnerability_report_credit_justification, documentation: { type: 'String', desc: 'vulnerability_report_credit_justification / 漏洞报告致谢状态说明', example: '' }
      expose :vulnerability_response_process_status, documentation: { type: 'String', desc: 'vulnerability_response_process_status / 漏洞响应流程状态', example: '' }
      expose :vulnerability_response_process_justification, documentation: { type: 'String', desc: 'vulnerability_response_process_justification / 漏洞响应流程状态说明', example: '' }
      expose :coding_standards_status, documentation: { type: 'String', desc: 'coding_standards_status / 编码标准状态', example: '' }
      expose :coding_standards_justification, documentation: { type: 'String', desc: 'coding_standards_justification / 编码标准状态说明', example: '' }
      expose :coding_standards_enforced_status, documentation: { type: 'String', desc: 'coding_standards_enforced_status / 编码标准执行状态', example: '' }
      expose :coding_standards_enforced_justification, documentation: { type: 'String', desc: 'coding_standards_enforced_justification / 编码标准执行状态说明', example: '' }
      expose :build_standard_variables_status, documentation: { type: 'String', desc: 'build_standard_variables_status / 构建标准变量状态', example: '' }
      expose :build_standard_variables_justification, documentation: { type: 'String', desc: 'build_standard_variables_justification / 构建标准变量状态说明', example: '' }
      expose :build_preserve_debug_status, documentation: { type: 'String', desc: 'build_preserve_debug_status / 构建保留调试信息状态', example: '' }
      expose :build_preserve_debug_justification, documentation: { type: 'String', desc: 'build_preserve_debug_justification / 构建保留调试信息状态说明', example: '' }
      expose :build_non_recursive_status, documentation: { type: 'String', desc: 'build_non_recursive_status / 非递归构建状态', example: '' }
      expose :build_non_recursive_justification, documentation: { type: 'String', desc: 'build_non_recursive_justification / 非递归构建状态说明', example: '' }
      expose :build_repeatable_status, documentation: { type: 'String', desc: 'build_repeatable_status / 构建可重复性状态', example: '' }
      expose :build_repeatable_justification, documentation: { type: 'String', desc: 'build_repeatable_justification / 构建可重复性状态说明', example: '' }
      expose :installation_standard_variables_status, documentation: { type: 'String', desc: 'installation_standard_variables_status / 安装标准变量状态', example: '' }
      expose :installation_standard_variables_justification, documentation: { type: 'String', desc: 'installation_standard_variables_justification / 安装标准变量状态说明', example: '' }
      expose :installation_development_quick_status, documentation: { type: 'String', desc: 'installation_development_quick_status / 开发环境快速安装状态', example: '' }
      expose :installation_development_quick_justification, documentation: { type: 'String', desc: 'installation_development_quick_justification / 开发环境快速安装状态说明', example: '' }
      expose :external_dependencies_status, documentation: { type: 'String', desc: 'external_dependencies_status / 外部依赖状态', example: '' }
      expose :external_dependencies_justification, documentation: { type: 'String', desc: 'external_dependencies_justification / 外部依赖状态说明', example: '' }
      expose :dependency_monitoring_status, documentation: { type: 'String', desc: 'dependency_monitoring_status / 依赖监控状态', example: '' }
      expose :dependency_monitoring_justification, documentation: { type: 'String', desc: 'dependency_monitoring_justification / 依赖监控状态说明', example: '' }
      expose :updateable_reused_components_status, documentation: { type: 'String', desc: 'updateable_reused_components_status / 可更新复用组件状态', example: '' }
      expose :updateable_reused_components_justification, documentation: { type: 'String', desc: 'updateable_reused_components_justification / 可更新复用组件状态说明', example: '' }
      expose :interfaces_current_status, documentation: { type: 'String', desc: 'interfaces_current_status / 接口时效性状态', example: '' }
      expose :interfaces_current_justification, documentation: { type: 'String', desc: 'interfaces_current_justification / 接口时效性状态说明', example: '' }
      expose :automated_integration_testing_status, documentation: { type: 'String', desc: 'automated_integration_testing_status / 自动化集成测试状态', example: '' }
      expose :automated_integration_testing_justification, documentation: { type: 'String', desc: 'automated_integration_testing_justification / 自动化集成测试状态说明', example: '' }
      expose :regression_tests_added50_status, documentation: { type: 'String', desc: 'regression_tests_added50_status / 50%回归测试新增状态', example: '' }
      expose :regression_tests_added50_justification, documentation: { type: 'String', desc: 'regression_tests_added50_justification / 50%回归测试新增状态说明', example: '' }
      expose :test_statement_coverage80_status, documentation: { type: 'String', desc: 'test_statement_coverage80_status / 80%语句测试覆盖率状态', example: '' }
      expose :test_statement_coverage80_justification, documentation: { type: 'String', desc: 'test_statement_coverage80_justification / 80%语句测试覆盖率状态说明', example: '' }
      expose :test_policy_mandated_status, documentation: { type: 'String', desc: 'test_policy_mandated_status / 强制测试策略状态', example: '' }
      expose :test_policy_mandated_justification, documentation: { type: 'String', desc: 'test_policy_mandated_justification / 强制测试策略状态说明', example: '' }
      expose :implement_secure_design_status, documentation: { type: 'String', desc: 'implement_secure_design_status / 安全设计实现状态', example: '' }
      expose :implement_secure_design_justification, documentation: { type: 'String', desc: 'implement_secure_design_justification / 安全设计实现状态说明', example: '' }
      expose :input_validation_status, documentation: { type: 'String', desc: 'input_validation_status / 输入验证状态', example: '' }
      expose :input_validation_justification, documentation: { type: 'String', desc: 'input_validation_justification / 输入验证状态说明', example: '' }
      expose :crypto_algorithm_agility_status, documentation: { type: 'String', desc: 'crypto_algorithm_agility_status / 加密算法灵活性状态', example: '' }
      expose :crypto_algorithm_agility_justification, documentation: { type: 'String', desc: 'crypto_algorithm_agility_justification / 加密算法灵活性状态说明', example: '' }
      expose :crypto_credential_agility_status, documentation: { type: 'String', desc: 'crypto_credential_agility_status / 加密凭证灵活性状态', example: '' }
      expose :crypto_credential_agility_justification, documentation: { type: 'String', desc: 'crypto_credential_agility_justification / 加密凭证灵活性状态说明', example: '' }
      expose :signed_releases_status, documentation: { type: 'String', desc: 'signed_releases_status / 发布签名状态', example: '' }
      expose :signed_releases_justification, documentation: { type: 'String', desc: 'signed_releases_justification / 发布签名状态说明', example: '' }
      expose :version_tags_signed_status, documentation: { type: 'String', desc: 'version_tags_signed_status / 版本标签签名状态', example: '' }
      expose :version_tags_signed_justification, documentation: { type: 'String', desc: 'version_tags_signed_justification / 版本标签签名状态说明', example: '' }
      expose :badge_percentage_2, documentation: { type: 'Float', desc: 'badge_percentage_2 / 徽章百分比2', example: 4 }
      expose :contributors_unassociated_status, documentation: { type: 'String', desc: 'contributors_unassociated_status / 非关联贡献者状态', example: '' }
      expose :contributors_unassociated_justification, documentation: { type: 'String', desc: 'contributors_unassociated_justification / 非关联贡献者状态说明', example: '' }
      expose :copyright_per_file_status, documentation: { type: 'String', desc: 'copyright_per_file_status / 文件版权声明状态', example: '' }
      expose :copyright_per_file_justification, documentation: { type: 'String', desc: 'copyright_per_file_justification / 文件版权声明状态说明', example: '' }
      expose :license_per_file_status, documentation: { type: 'String', desc: 'license_per_file_status / 文件许可证声明状态', example: '' }
      expose :license_per_file_justification, documentation: { type: 'String', desc: 'license_per_file_justification / 文件许可证声明状态说明', example: '' }
      expose :small_tasks_status, documentation: { type: 'String', desc: 'small_tasks_status / 小型任务状态', example: '' }
      expose :small_tasks_justification, documentation: { type: 'String', desc: 'small_tasks_justification / 小型任务状态说明', example: '' }
      expose :require_2FA_status, documentation: { type: 'String', desc: 'require_2FA_status / 双因素认证要求状态', example: '' }
      expose :require_2FA_justification, documentation: { type: 'String', desc: 'require_2FA_justification / 双因素认证要求状态说明', example: '' }
      expose :secure_2FA_status, documentation: { type: 'String', desc: 'secure_2FA_status / 安全双因素认证状态', example: '' }
      expose :secure_2FA_justification, documentation: { type: 'String', desc: 'secure_2FA_justification / 安全双因素认证状态说明', example: '' }
      expose :code_review_standards_status, documentation: { type: 'String', desc: 'code_review_standards_status / 代码审查标准状态', example: '' }
      expose :code_review_standards_justification, documentation: { type: 'String', desc: 'code_review_standards_justification / 代码审查标准状态说明', example: '' }
      expose :two_person_review_status, documentation: { type: 'String', desc: 'two_person_review_status / 双人审查状态', example: '' }
      expose :two_person_review_justification, documentation: { type: 'String', desc: 'two_person_review_justification / 双人审查状态说明', example: '' }
      expose :test_statement_coverage90_status, documentation: { type: 'String', desc: 'test_statement_coverage90_status / 90%语句测试覆盖率状态', example: '' }
      expose :test_statement_coverage90_justification, documentation: { type: 'String', desc: 'test_statement_coverage90_justification / 90%语句测试覆盖率状态说明', example: '' }
      expose :test_branch_coverage80_status, documentation: { type: 'String', desc: 'test_branch_coverage80_status / 80%分支测试覆盖率状态', example: '' }
      expose :test_branch_coverage80_justification, documentation: { type: 'String', desc: 'test_branch_coverage80_justification / 80%分支测试覆盖率状态说明', example: '' }
      expose :security_review_status, documentation: { type: 'String', desc: 'security_review_status / 安全审查状态', example: '' }
      expose :security_review_justification, documentation: { type: 'String', desc: 'security_review_justification / 安全审查状态说明', example: '' }
      expose :assurance_case_status, documentation: { type: 'String', desc: 'assurance_case_status / 保障案例状态', example: '' }
      expose :assurance_case_justification, documentation: { type: 'String', desc: 'assurance_case_justification / 保障案例状态说明', example: '' }
      expose :achieve_passing_status, documentation: { type: 'String', desc: 'achieve_passing_status / 达到通过状态', example: 'Met' }
      expose :achieve_passing_justification, documentation: { type: 'String', desc: 'achieve_passing_justification / 达到通过状态说明', example: '' }
      expose :achieve_silver_status, documentation: { type: 'String', desc: 'achieve_silver_status / 达到白银状态', example: 'Unmet' }
      expose :achieve_silver_justification, documentation: { type: 'String', desc: 'achieve_silver_justification / 达到白银状态说明', example: '' }
      expose :tiered_percentage, documentation: { type: 'Float', desc: 'tiered_percentage / 分层百分比', example: 105 }
      expose :repo_url_updated_at, documentation: { type: 'String', desc: 'repo_url_updated_at / 仓库URL更新时间', example: '' }
      expose :achieved_silver_at, documentation: { type: 'String', desc: 'achieved_silver_at / 达到白银状态时间', example: '' }
      expose :lost_silver_at, documentation: { type: 'String', desc: 'lost_silver_at / 失去白银状态时间', example: '' }
      expose :achieved_gold_at, documentation: { type: 'String', desc: 'achieved_gold_at / 达到黄金状态时间', example: '' }
      expose :lost_gold_at, documentation: { type: 'String', desc: 'lost_gold_at / 失去黄金状态时间', example: '' }
      expose :first_achieved_passing_at, documentation: { type: 'String', desc: 'first_achieved_passing_at / 首次达到通过状态时间', example: '2023-09-19T12:56:47.208Z' }
      expose :first_achieved_silver_at, documentation: { type: 'String', desc: 'first_achieved_silver_at / 首次达到白银状态时间', example: '' }
      expose :first_achieved_gold_at, documentation: { type: 'String', desc: 'first_achieved_gold_at / 首次达到黄金状态时间', example: '' }
      expose :maintained_status, documentation: { type: 'String', desc: 'maintained_status / 维护状态', example: 'Met' }
      expose :maintained_justification, documentation: { type: 'String', desc: 'maintained_justification / 维护状态说明', example: 'https://github.com/ossf/scorecard/blob/main/.github/CODEOWNERS' }
      expose :badge_level, documentation: { type: 'String', desc: 'badge_level / 徽章等级', example: 'passing' }
      expose :additional_rights, documentation: { type: 'Array', desc: 'additional_rights / 附加权限', example: [] }
      expose :project_entry_attribution, documentation: { type: 'String', desc: 'project_entry_attribution / 项目条目归属', example: 'Please credit Stephen Augustus (he/him) and the CII Best Practices badge contributors.' }
      expose :project_entry_license, documentation: { type: 'String', desc: 'project_entry_license / 项目条目许可证', example: 'CC-BY-3.0+'}
    end

  end
end
