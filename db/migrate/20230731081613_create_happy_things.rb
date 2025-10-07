# frozen_string_literal: true

class CreateHappyThings < ActiveRecord::Migration[7.0]
  def change
    create_table :happy_things do |t|
      t.string :title, null: false
      t.text :body
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
