# frozen_string_literal: true

class CreateCloseFriendsSubscribers < ActiveRecord::Migration[8.0]
  def change
    create_table :close_friends_subscribers do |t|
      t.string :email, null: false
      t.datetime :confirmed_at
      t.datetime :approved_at
      t.datetime :unsubscribed_at

      t.timestamps
    end

    add_index :close_friends_subscribers, :email, unique: true
  end
end
