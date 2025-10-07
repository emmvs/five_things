# frozen_string_literal: true

class CreateFriendships < ActiveRecord::Migration[7.0]
  def change
    create_table :friendships do |t|
      t.references :user, foreign_key: { to_table: :users }
      t.references :friend, foreign_key: { to_table: :users }
      t.boolean :accepted, default: false
      t.timestamps
    end
    add_index :friendships, %i[user_id friend_id], unique: true
  end
end
