class AddDateAndTimeToHappyThings < ActiveRecord::Migration[7.0]
  def change
    add_column :happy_things, :date, :date, default: Date.today
    add_column :happy_things, :time, :time, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
