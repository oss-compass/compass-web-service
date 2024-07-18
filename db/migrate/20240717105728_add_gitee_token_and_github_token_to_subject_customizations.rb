class AddGiteeTokenAndGithubTokenToSubjectCustomizations < ActiveRecord::Migration[7.1]
  def change
    add_column :subject_customizations, :gitee_token, :string, null: true
    add_column :subject_customizations, :github_token, :string, null: true
  end
end
