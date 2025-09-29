# frozen_string_literal: true

class AddOmniauthToUsers < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
  end
end
