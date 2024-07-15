# frozen_string_literal: true

class AddOptInsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_opt_in, :boolean, default: false
    add_column :users, :location_opt_in, :boolean, default: false
  end
end
