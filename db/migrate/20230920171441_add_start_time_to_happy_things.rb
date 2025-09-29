# frozen_string_literal: true

class AddStartTimeToHappyThings < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :happy_things, :start_time, :datetime
  end
end
