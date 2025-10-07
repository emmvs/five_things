# frozen_string_literal: true

class CreateHappyThingUserShares < ActiveRecord::Migration[7.0]
  def change
    create_table :happy_thing_user_shares do |t|
      t.references :happy_thing, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
