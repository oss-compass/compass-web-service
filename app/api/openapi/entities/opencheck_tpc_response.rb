# frozen_string_literal: true
module Openapi
  module Entities
    class ScorecardItem < Grape::Entity
      expose :'total-score', documentation: { type: 'int', desc: 'total-score', example: 6 }
      expose :'binary-artifacts', documentation: { type: 'int', desc: 'binary-artifacts', example: 10 }
      expose :'branch-protection', documentation: { type: 'int', desc: 'branch-protection', example: 0 }
      expose :'ci-tests', documentation: { type: 'int', desc: 'ci-tests', example: 0 }
      expose :'cii-best-practices', documentation: { type: 'int', desc: 'cii-best-practices', example: 0 }
      expose :'code-review', documentation: { type: 'int', desc: 'code-review', example: 5 }
      expose :contributors, documentation: { type: 'int', desc: 'contributors', example: 10 }
      expose :'dangerous-workflow', documentation: { type: 'int', desc: 'dangerous-workflow', example: -1 }
      expose :'dependency-update-tool', documentation: { type: 'int', desc: 'dependency-update-tool', example: 10 }
      expose :fuzzing, documentation: { type: 'int', desc: 'fuzzing', example: 0 }
      expose :license, documentation: { type: 'int', desc: 'license', example: 10 }
      expose :maintained, documentation: { type: 'int', desc: 'maintained', example: 10 }
      expose :packaging, documentation: { type: 'int', desc: 'packaging', example: -1 }
      expose :'pinned-dependencies', documentation: { type: 'int', desc: 'pinned-dependencies', example: -1 }
      expose :sast, documentation: { type: 'int', desc: 'sast', example: 0 }
      expose :'security-policy', documentation: { type: 'int', desc: 'security-policy', example: 10 }
      expose :'signed-releases', documentation: { type: 'int', desc: 'signed-releases', example: -1 }
      expose :'token-permissions', documentation: { type: 'int', desc: 'token-permissions', example: -1 }
      expose :vulnerabilities, documentation: { type: 'int', desc: 'vulnerabilities', example: 8 }
    end

    class TpcItem < Grape::Entity
      expose :scorecard, using: Entities::ScorecardItem, documentation: { type: 'Entities::ScorecardItem', desc: 'response',
                                                                          param_type: 'body' }
    end

    class OpencheckTpcResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'count / 总数', example: 100 }
      expose :items, using: Entities::TpcItem, documentation: { type: 'Entities::TpcItem', desc: 'response',
                                                                param_type: 'body', is_array: true }
    end
  end
end
