# frozen_string_literal: true

class CreateEssenceSubscribers < ActiveRecord::Migration[8.0]
  def change
    drop_stale_tables
    create_essence_subscribers_table
  end

  private

  def drop_stale_tables
    drop_table :close_friends_issues, if_exists: true
    drop_table :close_friends_subscribers, if_exists: true
  end

  def create_essence_subscribers_table
    create_table :essence_subscribers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :locale, null: false, default: 'en'
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at

      t.timestamps
    end

    add_index :essence_subscribers, :email, unique: true
  end
end
