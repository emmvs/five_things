# frozen_string_literal: true

class AddPlacesToHappyThings < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :happy_things, :place, :string
    add_column :happy_things, :latitude, :float
    add_column :happy_things, :longitude, :float
  end
end
