class AddStartTimeToHappyThings < ActiveRecord::Migration[7.0]
  def change
    add_column :happy_things, :start_time, :datetime, default: DateTime.now
  end
end
