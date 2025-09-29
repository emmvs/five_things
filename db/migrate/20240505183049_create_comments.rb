# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :happy_thing, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
