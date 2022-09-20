module Types
  class MutationType < Types::BaseObject
    field :create_repo_task, mutation: Mutations::CreateRepoTask, description: 'Submit a repository analysis task'
    field :create_project_task, mutation: Mutations::CreateProjectTask, description: 'Submit a project analysis task'
  end
end
