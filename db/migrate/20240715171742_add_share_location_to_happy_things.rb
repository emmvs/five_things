# frozen_string_literal: true

class AddShareLocationToHappyThings < ActiveRecord::Migration[7.0]
  def change
    add_column :happy_things, :share_location, :boolean
  end
end
