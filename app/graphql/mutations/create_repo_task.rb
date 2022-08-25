module Mutations
  class CreateRepoTask < BaseMutation
    graphql_name 'CreateRepoTask'

    field :status, String, null: false

    argument :repo_url, String, required: true, description: 'Target repository url'
    argument :raw, Boolean, required: false, description: 'Whether to execute the raw fetch task'
    argument :enrich, Boolean, required: false, description: 'Whether to execute the enrich task'
    argument :activity, Boolean, required: false, description: 'Whether to calculate the activity model'
    argument :community, Boolean, required: false, description: 'Whether to calculate the community model'
    argument :codequality, Boolean, required: false, description: 'Whether to calculate the codequality model'


    def resolve(
          repo_url:,
          raw: true,
          enrich: true,
          activity: true,
          community: true,
          codequality: true
        )

      result =
        AnalyzeServer.new(
          {
            repo_url: repo_url,
            raw: raw,
            enrich: enrich,
            activity: activity,
            community: community,
            codequality: codequality
          }
        ).execute

      { status: result[:status], message: result[:message] }
    end
  end
end
