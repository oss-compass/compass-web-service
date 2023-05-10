module Types
  class MutationType < Types::BaseObject
    field :create_repo_task, mutation: Mutations::CreateRepoTask, description: 'Submit a repository analysis task'
    field :create_project_task, mutation: Mutations::CreateProjectTask, description: 'Submit a community analysis task'
    field :sign_out, Boolean, description: 'Sign out'
    field :destroy_user, Boolean, description: 'Destroy user'

    def sign_out
      context[:sign_out].call(context[:current_user]) if context[:current_user].present?
      true
    end

    def destroy_user
      user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if user.blank?

      user.destroy
      true
    end

    # field :create_collection, mutation: Mutations::CreateCollection, description: 'Create a compass collection'
    # field :delete_collection, mutation: Mutations::DeleteCollection, description: 'Delete a compass collection'
    # field :create_keyword, mutation: Mutations::CreateKeyword, description: 'Create a compass keyword'
    # field :delete_keyword, mutation: Mutations::DeleteKeyword, description: 'Delete a compass keyword'

    # field :append_keyword_to_collection, mutation: Mutations::AppendKeywordToCollection, description: 'Append a keyword to a collection'
    # field :detach_keyword_from_collection, mutation: Mutations::DetachKeywordFromCollection, description: 'Detach a keyword from a collection'

    # field :append_project_to_collection, mutation: Mutations::AppendProjectToCollection, description: 'Append a repo or community to a collection'
    # field :detach_project_from_collection, mutation: Mutations::DetachProjectFromCollection, description: 'Detach a repo or community from a collection'

    # field :append_keyword_to_project, mutation: Mutations::AppendKeywordToProject, description: 'Append a keyword to a repo or community'
    # field :detach_keyword_from_project, mutation: Mutations::DetachKeywordFromProject, description: 'Detach a keyword from a repo or community'
  end
end
