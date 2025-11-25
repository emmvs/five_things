# frozen_string_literal: true

class AddTimezoneToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :timezone, :string, default: 'UTC'
  end
end
