# frozen_string_literal: true

class CreateDailyHappyEmailDeliveries < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_happy_email_deliveries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.datetime :delivered_at, null: false

      t.timestamps
    end
  end
end
