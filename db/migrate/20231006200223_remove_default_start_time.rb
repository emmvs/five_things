# frozen_string_literal: true

class RemoveDefaultStartTime < ActiveRecord::Migration[6.0]
  def up
    change_column_default :happy_things, :start_time, nil
  end
end
