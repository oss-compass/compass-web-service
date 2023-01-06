module Types
  class MutationType < Types::BaseObject
    field :create_repo_task, mutation: Mutations::CreateRepoTask, description: 'Submit a repository analysis task'
    field :create_project_task, mutation: Mutations::CreateProjectTask, description: 'Submit a project analysis task'
    field :create_collection, mutation: Mutations::CreateCollection, description: 'Create a compass collection'
    field :delete_collection, mutation: Mutations::DeleteCollection, description: 'Delete a compass collection'
    field :create_keyword, mutation: Mutations::CreateKeyword, description: 'Create a compass keyword'
    field :delete_keyword, mutation: Mutations::DeleteKeyword, description: 'Delete a compass keyword'
  end
end
