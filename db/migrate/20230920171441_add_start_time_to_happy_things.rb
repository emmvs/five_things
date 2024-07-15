# frozen_string_literal: true

class AddStartTimeToHappyThings < ActiveRecord::Migration[7.0]
  def change
    add_column :happy_things, :start_time, :datetime
  end
end
