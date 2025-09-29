# frozen_string_literal: true

class AddShareLocationToHappyThings < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :happy_things, :share_location, :boolean
  end
end
