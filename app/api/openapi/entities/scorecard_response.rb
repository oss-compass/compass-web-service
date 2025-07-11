# frozen_string_literal: true
module Openapi
  module Entities

    class ScorecardResponse < Grape::Entity
      expose :uuid, documentation: { type: 'String', desc: 'Unique Identifier / 唯一标识符', example: "9497744d49ae8c0eba2b657d55a178a4b12c2b77" }
      expose :level, documentation: { type: 'String', desc: 'Analysis Level / 分析层级', example: "repo" }
      expose :type, documentation: { type: 'String', desc: 'Type / 类型', example: '' }
      expose :label, documentation: { type: 'String', desc: 'Repository URL / 仓库地址', example: "https://github.com/oss-compass/compass-web-service" }
      expose :model_name, documentation: { type: 'String', desc: 'Model Name / 模型名称', example: "Scorecard" }

      expose :score, documentation: { type: 'Float', desc: 'score of scorecard / Scorecard 得分', example: 10}
      expose :binary_artifacts, documentation: { type: 'Float', desc: 'Is the project free of checked-in binaries / 该项目是否没有签入的二进制文件', example: 10 }
      expose :branch_protection, documentation: { type: 'Float', desc: 'Does the project use Branch Protection / 项目是否使用分支保护', example: 10 }
      expose :ci_tests, documentation: { type: 'Float', desc: 'Does the project run tests in CI / 该项目是否在 CI 中运行测试', example: 10 }
      expose :cii_best_practices, documentation: { type: 'Float', desc: 'Has the project earned an OpenSSF (formerly CII) Best Practices Badge at the passing, silver, or gold level / 该项目是否获得了及格、银级或金级的 OpenSSF（以前称为 CII）最佳实践徽章', example: 10 }
      expose :code_review, documentation: { type: 'Float', desc: 'Does the project practice code review before code is merged / 项目在代码合并之前是否进行代码审查', example: 10 }
      expose :contributors, documentation: { type: 'Float', desc: 'Does the project have contributors from at least two different organizations / 该项目是否有来自至少两个不同组织的贡献者', example: 10 }
      expose :dangerous_workflow, documentation: { type: 'Float', desc: 'Does the project avoid dangerous coding patterns in  Action workflows / 项目是否避免了 Action 工作流中的危险编码模式', example: 10 }
      expose :dependency_update_tool, documentation: { type: 'Float', desc: 'Does the project use tools to help update its dependencies / 项目是否使用工具来帮助更新其依赖项', example: 10 }
      expose :fuzzing, documentation: { type: 'Float', desc: 'Does the project use fuzzing tools / 项目是否使用模糊测试工具', example: 10 }
      expose :license, documentation: { type: 'Float', desc: 'Does the project declare a license / 项目是否声明许可证', example: 10 }
      expose :maintained, documentation: { type: 'Float', desc: 'Is the project at least 90 days old, and maintained / 该项目是否至少已存在 90 天，并且维护', example: 10 }
      expose :packaging, documentation: { type: 'Float', desc: 'Does the project build and publish official packages from CI/CD / 项目是否从 CI/CD 构建并发布官方软件包', example: 10 }
      expose :pinned_dependencies, documentation: { type: 'Float', desc: 'Does the project declare and pin dependencies / 项目是否声明并固定依赖关系', example: 10 }
      expose :sast, documentation: { type: 'Float', desc: 'Does the project use static code analysis tools / 项目是否使用静态代码分析工具', example: 10 }
      expose :sbom, documentation: { type: 'Float', desc: 'This check tries to determine if the project maintains a Software Bill of Materials (SBOM) either as a file in the source or a release artifact. / 该检查尝试确定项目是否以源文件或发布工件的形式维护软件物料清单 (SBOM)', example: 10 }
      expose :security_policy, documentation: { type: 'Float', desc: 'Does the project contain a security policy / 项目是否包含安全策略', example: 10 }
      expose :signed_releases, documentation: { type: 'Float', desc: 'Does the project cryptographically sign releases / 项目是否对发布进行加密签名', example: 10 }
      expose :token_permissions, documentation: { type: 'Float', desc: 'Does the project declare workflow tokens as read only / 项目是否将工作流令牌声明为只读', example: 10 }
      expose :vulnerabilities, documentation: { type: 'Float', desc: 'Does the project have unfixed vulnerabilities / 项目是否存在未修复的漏洞', example: 10 }
      expose :webhooks, documentation: { type: 'Float', desc: 'Does the webhook defined in the repository have a token configured to authenticate the origins of requests / 存储库中定义的 webhook 是否配置了用于验证请求来源的令牌', example: 10 }

      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'Metric Calculation Time / 指标计算时间', example: "2022-07-18T00:00:00+00:00" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'Metadata Update Time / 元数据更新时间', example: "2024-01-17T22:47:46.075025+00:00" }

    end

  end
end
