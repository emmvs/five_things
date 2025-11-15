# frozen_string_literal: true

class AddOuraTokensToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :oura_access_token, :string
    add_column :users, :oura_refresh_token, :string
    add_column :users, :oura_token_expires_at, :datetime
    add_column :users, :oura_user_id, :string

    add_index :users, :oura_user_id
  end
end
