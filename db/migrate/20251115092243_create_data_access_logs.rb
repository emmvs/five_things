# frozen_string_literal: true

class CreateDataAccessLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :data_access_logs do |t|
      t.integer :user_id
      t.string :accessed_model
      t.integer :accessed_id
      t.string :action
      t.string :ip_address
      t.text :user_agent
      t.jsonb :metadata, default: {}
      t.datetime :accessed_at

      t.timestamps
    end

    add_index :data_access_logs, :user_id
    add_index :data_access_logs, %i[accessed_model accessed_id]
    add_index :data_access_logs, :accessed_at
  end
end
