# frozen_string_literal: true

class AddNotifiedFriendsOnToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :notified_friends_on, :date
  end
end
