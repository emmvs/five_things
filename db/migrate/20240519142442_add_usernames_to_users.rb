# frozen_string_literal: true

class AddUsernamesToUsers < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :users, :username, :string
  end
end
