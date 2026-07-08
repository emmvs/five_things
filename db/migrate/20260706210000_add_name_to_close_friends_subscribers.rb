# frozen_string_literal: true

class AddNameToCloseFriendsSubscribers < ActiveRecord::Migration[8.0]
  def change
    add_column :close_friends_subscribers, :name, :string, null: false, default: ''
    change_column_default :close_friends_subscribers, :name, from: '', to: nil
  end
end
