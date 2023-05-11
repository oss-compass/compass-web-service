class AddEmailVerificationTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_verification_token, :string
    add_column :users, :email_verification_sent_at, :datetime
    add_column :users, :name, :string
  end
end
