module Types
  class MutationType < Types::BaseObject
    field :create_repo_task, mutation: Mutations::CreateRepoTask, description: 'Submit a repository analysis task'
  end
end
