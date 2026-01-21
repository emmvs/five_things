# frozen_string_literal: true

class CreateUserConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :user_configs do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :install_prompt_shown, default: false, null: false

      t.timestamps
    end
  end
end
