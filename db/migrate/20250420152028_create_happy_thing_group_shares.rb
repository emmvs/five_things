# frozen_string_literal: true

class CreateHappyThingGroupShares < ActiveRecord::Migration[7.0]
  def change
    create_table :happy_thing_group_shares do |t|
      t.references :happy_thing, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
